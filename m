From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] tcp: Schedule rmem for rcvq repair send
Date: Thu, 10 May 2012 14:00:29 +0200
Message-ID: <1336651229.12504.150.camel@edumazet-glaptop>
References: <4FABAB39.6090201@parallels.com>  <4FABAB69.70401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48717 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756301Ab2EJMAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 08:00:33 -0400
Received: by mail-bk0-f46.google.com with SMTP id ji2so1195838bkc.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 05:00:32 -0700 (PDT)
In-Reply-To: <4FABAB69.70401@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-10 at 15:50 +0400, Pavel Emelyanov wrote:
> As noted by Eric, no checks are performed on the data size we're
> putting in the read queue during repair. Thus, validate the given
> data size with the common rmem management routine.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> ---
>  net/ipv4/tcp_input.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
