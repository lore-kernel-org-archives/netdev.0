From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 01/05] ipv6: RFC4214 Support (2)
Date: Wed, 7 Nov 2007 17:12:09 -0800
Message-ID: <20071107171209.7da68d88@freepuppy.rosehill>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE2@XCH-NW-7V2.nw.nos.boeing.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC04@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41846 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752538AbXKHBNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 20:13:53 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC04@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Nov 2007 17:08:50 -0800
"Templin, Fred L" <Fred.L.Templin@boeing.com> wrote:

> 
> From: Fred L. Templin <fred.l.templin@boeing.com>
>  
> This is experimental support for the Intra-Site Automatic
> Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
> the SIT module, and is configured using the unmodified
> "ip" utility with device names beginning with: "isatap".
> 
> The following diffs are specific to the Linux 2.6.23
> kernel distribution.

Please submit all patches against the latest kernel (2.6.24-rc2 now).
Otherwise, it gets hard to do integration.

> ---
> 
> --- linux-2.6.23/include/linux/if.h.orig	2007-10-29
> 09:22:26.000000000 -0700
> +++ linux-2.6.23/include/linux/if.h	2007-11-07 13:48:08.000000000
> -0800
> @@ -61,6 +61,7 @@
>  #define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.
> */
>  #define IFF_BONDING	0x20		/* bonding master or slave
> */
>  #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation
> */
> +#define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)
> */

Your mail client is wrapping the patch.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
