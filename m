From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 6 Aug 2014 10:23:25 -0400
Message-ID: <CA+FuTSf96KH=JkO4Va4pfbvYHngHjxtTc33ipbif_xC9kdgaLQ@mail.gmail.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
 <1407204710-21778-6-git-send-email-willemb@google.com> <1407308749.14097.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:39752 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbaHFOX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 10:23:56 -0400
Received: by mail-qg0-f54.google.com with SMTP id z60so2801834qgd.27
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 07:23:55 -0700 (PDT)
In-Reply-To: <1407308749.14097.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I believe you missed fact that a GSO packet can be split into 2 or many
> skbs, when tcp_write_xmit() has to send a lower amount.
>
> This is done in tso_fragment()

Thanks, I missed that case. I'll look into it.

> Also, I am a bit worried about retransmits ?

For the same reason, i.e., possibly calling tcp_fragment?
