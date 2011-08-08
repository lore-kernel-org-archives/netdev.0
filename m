From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 11/12] headers, scc: Add missing #include to
 <linux/scc.h>
Date: Mon, 8 Aug 2011 19:20:18 +0100
Message-ID: <20110808182018.GG29924@decadent.org.uk>
References: <1312809302.2591.1139.camel@deadeye>
 <1312809869.2591.1151.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>,
	Klaus Kudielka <klaus.kudielka@ieee.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36284 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753865Ab1HHSUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 14:20:24 -0400
Content-Disposition: inline
In-Reply-To: <1312809869.2591.1151.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 08, 2011 at 02:24:29PM +0100, Ben Hutchings wrote:
> <linux/scc.h> uses SIOCDEVPRIVATE, defined in <linux/sockios.h>.
 
Unfortunately SIOCDEVPRIVATE is also defined elsewhere by glibc,
so including <linux/sockios.h> can result in duplicate definitions.
So I don't think we can make this change.

Ben.

> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> This file isn't listed in MAINTAINERS but appears to be associated with
> one of the hamradio drivers; please could one of the hams claim it?
> 
> Ben.
> 
>  include/linux/scc.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/scc.h b/include/linux/scc.h
> index 3495bd9..d5916e5 100644
> --- a/include/linux/scc.h
> +++ b/include/linux/scc.h
> @@ -3,6 +3,7 @@
>  #ifndef	_SCC_H
>  #define	_SCC_H
>  
> +#include <linux/sockios.h>
>  
>  /* selection of hardware types */
>  
> -- 
> 1.7.5.4
> 
> 
> 

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
