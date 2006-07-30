From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 3/23] [PATCH] [XFRM]: Add Kconfig to enable advanced
 transformation.
Date: Sun, 30 Jul 2006 18:12:02 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607301810080.26424@d.namei>
References: <11541654012846-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:13709 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932477AbWG3WME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 18:12:04 -0400
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <11541654012846-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 29 Jul 2006, Masahide NAKAMURA wrote:

> This option is for enhanced transformation features and it will be used by
> Mobile IPv6.
> Based on MIPL2 kernel patch.
> ---
>  net/xfrm/Kconfig |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
> index 0c1c043..95f4f09 100644
> --- a/net/xfrm/Kconfig
> +++ b/net/xfrm/Kconfig
> @@ -14,6 +14,14 @@ config XFRM_USER
>  
>  	  If unsure, say Y.
>  
> +config XFRM_ADVANCED
> +	bool "Transformation advanced functions (EXPERIMENTAL)"
> +	depends on XFRM && EXPERIMENTAL
> +	---help---
> +	  Support advanced transformation for developers.
> +
> +	  If unsure, say N.
> +
>  config NET_KEY
>  	tristate "PF_KEY sockets"
>  	select XFRM
> 

Do we really need to add this config item? 
I think we should just enable it.



- James
-- 
James Morris
<jmorris@namei.org>
