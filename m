From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 06 Aug 2014 16:36:21 +0200
Message-ID: <1407335781.11943.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
	 <1407204710-21778-6-git-send-email-willemb@google.com>
	 <1407308141.14097.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+FuTSdqxXOod_V6+cfYdLgFZ1mabi1O34UT92XEpqGiFtfz1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:44581 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826AbaHFOgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 10:36:25 -0400
Received: by mail-wi0-f181.google.com with SMTP id bs8so3313908wib.8
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 07:36:24 -0700 (PDT)
In-Reply-To: <CA+FuTSdqxXOod_V6+cfYdLgFZ1mabi1O34UT92XEpqGiFtfz1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-08-06 at 09:08 -0400, Willem de Bruijn wrote:

> Thanks for spotting and fixing the critical shared frags issue. I
> can send a patch for this, the two static functions identified by
> sparse and the sequence number arithmetic in tcp_gso_tstamp.

Please send the patch, as I am quite busy today.

Another issue is your should set the flag, not clearing others in
tcp_gso_tstamp()

	skb_shinfo(skb)->tx_flags |= SKBTX_SW_TSTAMP;


Not sure if this matters at the moment, but it would be cleaner anyway.
