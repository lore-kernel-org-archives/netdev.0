From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Sat, 12 Apr 2008 04:50:03 -0400
Message-ID: <480077BB.4000109@garzik.org>
References: <m3prtzsszg.fsf@maximus.localdomain>	<m3tzj92xq6.fsf@maximus.localdomain>	<m33aqedg0a.fsf@maximus.localdomain>	<m37if4oz1g.fsf@maximus.localdomain>	<20080411221448.22b69ff5.akpm@linux-foundation.org> <m3prsva3y7.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41456 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760494AbYDLIuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 04:50:08 -0400
In-Reply-To: <m3prsva3y7.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> --- a/drivers/net/wan/Kconfig
> +++ b/drivers/net/wan/Kconfig
> @@ -150,9 +150,13 @@ config HDLC_FR
>  
>  config HDLC_PPP
>  	tristate "Synchronous Point-to-Point Protocol (PPP) support"
> -	depends on HDLC
> +	depends on HDLC && BROKEN
>  	help
>  	  Generic HDLC driver supporting PPP over WAN connections.
> +	  This module is currently broken and will cause a kernel panic
> +	  when a device configured in PPP mode is activated.
> +
> +	  It will be replaced by new PPP implementation in Linux 2.6.26.
>  
>  	  If unsure, say N.


applied

