From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: add server ip to encrypt cookie in fast open
Date: Thu, 08 Aug 2013 14:52:43 -0700
Message-ID: <1375998763.4004.132.camel@edumazet-glaptop>
References: <1375995982-17862-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:43361 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758094Ab3HHVwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 17:52:45 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so3895445pbc.21
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 14:52:44 -0700 (PDT)
In-Reply-To: <1375995982-17862-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-08 at 14:06 -0700, Yuchung Cheng wrote:
> Encrypt the cookie with both server and client IPv4 addresses,
> such that multi-homed server will grant different cookies
> based on both the source and destination IPs. No client change
> is needed since cookie is opaque to the client.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  include/net/tcp.h       |  3 ++-
>  net/ipv4/tcp_fastopen.c | 13 ++++++-------
>  net/ipv4/tcp_ipv4.c     | 10 +++++++---
>  3 files changed, 15 insertions(+), 11 deletions(-)

Reviewed-by: Eric Dumazet <edumazet@google.com>

I presume this is net-next material ?
