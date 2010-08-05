From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 3/3] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Wed, 4 Aug 2010 21:22:51 -0400
Message-ID: <20100804212251.59c08e58.billfink@mindspring.com>
References: <E1OgbWT-0004Ij-00.xeb-mail-ru@f134.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:43144 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751855Ab0HEBaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 21:30:04 -0400
In-Reply-To: <E1OgbWT-0004Ij-00.xeb-mail-ru@f134.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 04 Aug 2010, xeb@mail.ru wrote:

> This is patch 3/3 which contains MAINTAINERS file modification.
> 
> ---
>  MAINTAINERS |   14 ++++++++++++++
>  1 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 02f75fc..313d829 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6450,6 +6450,20 @@ M:	"Maciej W. Rozycki" <macro@linux-mips.org>
>  S:	Maintained
>  F:	drivers/serial/zs.*
>  
> +GRE DEMULTIPLEXER DRIVER
> +M:	Dmitry Kozlov <xeb@mail.ru>
> +L:	linux-net@vger.kernel.org

Shouldn't this also be:

+L:	netdev@vger.kernel.org

just like the PPTP DRIVER entry below?

			-Bill



> +S:	Maintained
> +F:	net/ipv4/gre.c
> +F:	include/net/gre.h
> +
> +PPTP DRIVER
> +M:	Dmitry Kozlov <xeb@mail.ru>
> +L:	netdev@vger.kernel.org
> +S:	Maintained
> +F:	drivers/net/pptp.c
> +W:	http://accel-pptp.sourceforge.net/
> +
>  THE REST
>  M:	Linus Torvalds <torvalds@linux-foundation.org>
>  L:	linux-kernel@vger.kernel.org
