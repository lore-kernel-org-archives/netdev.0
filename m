From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] net-timestamp: sock_tx_timestamp() fix
Date: Wed, 6 Aug 2014 08:52:14 -0400
Message-ID: <CA+FuTSeO2znQrvm=2ekoxNMihP+06f4E2mSthN=Wn_0NZi7=EQ@mail.gmail.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
 <1407204710-21778-6-git-send-email-willemb@google.com> <1407308749.14097.13.camel@edumazet-glaptop2.roam.corp.google.com>
 <1407318569.11943.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:62440 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbaHFMwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 08:52:45 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so2559185qgf.7
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 05:52:44 -0700 (PDT)
In-Reply-To: <1407318569.11943.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 6, 2014 at 5:49 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> sock_tx_timestamp() should not ignore initial *tx_flags value, as TCP
> stack can store SKBTX_SHARED_FRAG in it.
>
> Also first argument (struct sock *) can be const.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 4ed2d765dfac ("net-timestamp: TCP timestamping")
> Cc: Willem de Bruijn <willemb@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>

Thanks, Eric!
