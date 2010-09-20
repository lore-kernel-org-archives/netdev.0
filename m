From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xmit_compl_seq: information to reclaim vmsplice buffers
Date: Sun, 19 Sep 2010 17:35:34 -0700 (PDT)
Message-ID: <20100919.173534.70176148.davem@davemloft.net>
References: <alpine.DEB.1.00.1009191451090.5120@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sridharr@google.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50768
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752935Ab0ITAfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Sep 2010 20:35:15 -0400
In-Reply-To: <alpine.DEB.1.00.1009191451090.5120@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 19 Sep 2010 14:55:40 -0700 (PDT)

> diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
> index 9a6115e..6dc1ed8 100644
> --- a/include/asm-generic/socket.h
> +++ b/include/asm-generic/socket.h
> @@ -64,4 +64,7 @@
>  #define SO_DOMAIN		39
>  
>  #define SO_RXQ_OVFL             40
> +
> +#define SO_XMIT_COMPL_SEQ	41
> +#define SCM_XMIT_COMPL_SEQ	SO_XMIT_COMPL_SEQ
>  #endif /* __ASM_GENERIC_SOCKET_H */

Tom, I just noticed that you're going to have to update all of
the arch specific arch/*/include/asm/socket.h files that don't
make use of asm-generic/socket.h before I can apply this.

Please fix this up and resubmit, thanks!
