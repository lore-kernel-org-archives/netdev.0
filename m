From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2: resend of patches from Debian.
Date: Thu, 11 Oct 2007 23:05:39 +0200
Message-ID: <470E9023.1010803@trash.net>
References: <1192127132.4732.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37567 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbXJKVF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 17:05:59 -0400
In-Reply-To: <1192127132.4732.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Henriksson wrote:
> Add mpath to ip manpage.
> 
> From: Norbert Buchmuller <norbi@nix.hu>
> 
> The 'mpath' parameter of 'ip route' is not documented in the manual page
> nor in ip-cref.tex.
> 
> ...huge part of the text in the patch was taken from the net/ipv4/Kconfig
> file in the Linux kernel source (2.6.18). I suppose that's OK because both
> Linux and iproute2 are GPL'd, but I let you know anyway.
> 
> See Debian bug #428442 - http://bugs.debian.org/428442
> 
> diff -Naur iproute-20061002/doc/ip-cref.tex iproute-20061002.fixed/doc/ip-cref.tex
> --- iproute-20061002/doc/ip-cref.tex	2007-06-11 19:26:52.000000000 +0200
> +++ iproute-20061002.fixed/doc/ip-cref.tex	2007-06-11 20:34:09.000000000 +0200
> @@ -1348,6 +1348,28 @@
>  route reflecting its relative bandwidth or quality.
>  \end{itemize}
>  
> +\item \verb|mpath MP_ALGO|


This has been removed from the kernel again because of complete
brokeness, so this patch shouldn't be merged.
