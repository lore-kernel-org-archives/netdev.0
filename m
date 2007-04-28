From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] netpoll: remove CONFIG_NETPOLL_RX
Date: Sat, 28 Apr 2007 22:52:36 +0400
Message-ID: <200704282252.36591.sshtylyov@ru.mvista.com>
References: <200704282248.52072.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	mpm@selenic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:41762 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753544AbXD1Su7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 14:50:59 -0400
In-Reply-To: <200704282248.52072.sshtylyov@ru.mvista.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 28 April 2007 22:48, Sergei Shtylyov wrote:
> Get rid of the CONFIG_NETPOLL_RX option completely since all the
> dependencies have been removed long ago...

   Same here:

> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Acked-by: Jeff Garzik <jgarzik@pobox.com>
Acked-by: Matt Mackall <mpm@selenic.com>

> ---
> See commit e3c265bcf67f21d847e970e71504890f61f37824 in tglx/history.git for
> the patch that removed the #ifdef's.
>
>  drivers/net/Kconfig       |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
>
> Index: linux-2.6/drivers/net/Kconfig
> ===================================================================
> --- linux-2.6.orig/drivers/net/Kconfig
> +++ linux-2.6/drivers/net/Kconfig
> @@ -2928,11 +2928,6 @@ endif #NETDEVICES
>  config NETPOLL
>  	def_bool NETCONSOLE
>
> -config NETPOLL_RX
> -	bool "Netpoll support for trapping incoming packets"
> -	default n
> -	depends on NETPOLL
> -
>  config NETPOLL_TRAP
>  	bool "Netpoll traffic trapping"
>  	default n

