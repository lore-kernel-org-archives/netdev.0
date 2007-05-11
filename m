From: Brian Haley <brian.haley@hp.com>
Subject: Re: [patch 4/8] Use menuconfig objects: SCTP
Date: Fri, 11 May 2007 09:45:16 -0400
Message-ID: <4644736C.4000808@hp.com>
References: <200705110553.l4B5rkFq007858@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jengelh@linux01.gwdg.de, jengelh@gmx.de, sri@us.ibm.com,
	vladislav.yasevich@hp.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:53069 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750998AbXEKNpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 09:45:19 -0400
In-Reply-To: <200705110553.l4B5rkFq007858@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> diff -puN net/sctp/Kconfig~use-menuconfig-objects-sctp net/sctp/Kconfig
> --- a/net/sctp/Kconfig~use-menuconfig-objects-sctp
> +++ a/net/sctp/Kconfig
> @@ -2,11 +2,9 @@
>  # SCTP configuration
>  #
>  
> -menu "SCTP Configuration (EXPERIMENTAL)"
> -	depends on INET && EXPERIMENTAL
> -
> -config IP_SCTP
> +menuconfig IP_SCTP
>  	tristate "The SCTP Protocol (EXPERIMENTAL)"
> +	depends on NET && EXPERIMENTAL
>  	depends on IPV6 || IPV6=n
>  	select CRYPTO if SCTP_HMAC_SHA1 || SCTP_HMAC_MD5
>  	select CRYPTO_HMAC if SCTP_HMAC_SHA1 || SCTP_HMAC_MD5

This just changed "INET && EXPERIMENTAL" to "NET && EXPERIMENTAL", don't 
know if that was intended.

-Brian
