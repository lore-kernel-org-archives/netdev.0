From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] tcp: Move rcvq sending to tcp_input.c
Date: Thu, 10 May 2012 14:00:14 +0200
Message-ID: <1336651214.12504.149.camel@edumazet-glaptop>
References: <4FABAB39.6090201@parallels.com>
	 <4FABAB55.5050803@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48717 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756275Ab2EJMAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 08:00:19 -0400
Received: by bkcji2 with SMTP id ji2so1195838bkc.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 05:00:18 -0700 (PDT)
In-Reply-To: <4FABAB55.5050803@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-10 at 15:49 +0400, Pavel Emelyanov wrote:
> It actually works on the input queue and will use its read mem
> routines, thus it's better to have in in the tcp_input.c file.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> ---
>  include/net/tcp.h    |    3 +--
>  net/ipv4/tcp.c       |   33 ---------------------------------
>  net/ipv4/tcp_input.c |   35 ++++++++++++++++++++++++++++++++++-
>  3 files changed, 35 insertions(+), 36 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
