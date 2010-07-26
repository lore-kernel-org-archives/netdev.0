From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: Make COMPAT_NETLINK_MESSAGES depend upon
 WEXT_CORE
Date: Mon, 26 Jul 2010 22:18:54 +0200
Message-ID: <1280175534.20917.2.camel@jlt3.sipsolutions.net>
References: <20100726.131506.245381776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:40533 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753751Ab0GZUSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 16:18:54 -0400
In-Reply-To: <20100726.131506.245381776.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-07-26 at 13:15 -0700, David Miller wrote:
> WIRELESS_EXT is not the correct dependency.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> 
> Wireless folks, just FYI, I will commit this to net-next-2.6
> 
>  net/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/Kconfig b/net/Kconfig
> index b325094..e24fa08 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -32,7 +32,7 @@ config WANT_COMPAT_NETLINK_MESSAGES
>  config COMPAT_NETLINK_MESSAGES
>  	def_bool y
>  	depends on COMPAT
> -	depends on WIRELESS_EXT || WANT_COMPAT_NETLINK_MESSAGES
> +	depends on WEXT_CORE || WANT_COMPAT_NETLINK_MESSAGES

You're right, thank you, I missed that at the time I changed this.

FWIW, it seems I broke this in 2.6.32! Guess nobody noticed since most
people actually do still have WIRELESS_EXT, especially distros.

johannes

