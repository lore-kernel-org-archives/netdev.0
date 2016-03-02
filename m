From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] net: moxa: fix an error code
Date: Wed, 2 Mar 2016 14:21:29 +0300
Message-ID: <20160302112129.GQ5273@mwanda>
References: <20160302101110.GI5533@mwanda>
 <7083740.CtlZQWRYiM@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jonas Jensen <jonas.jensen@gmail.com>,
	Luis de Bethencourt <luis@debethencourt.com>,
	=?iso-8859-1?Q?fran=E7ois?= romieu <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20404 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbcCBLVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 06:21:47 -0500
Content-Disposition: inline
In-Reply-To: <7083740.CtlZQWRYiM@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2016 at 11:52:29AM +0100, Arnd Bergmann wrote:
> Did you find more of these?
> 
> it doesn't matter much either way, but if you do multiple such patches,

One or two.  I already sent the fixes.  I think it was applied.

> I'd suggest using a single PTR_ERR_OR_ZERO() instead of IS_ERR()+PTR_ERR().
> 
> I have found a couple of drivers in which that leads to better object
> code, and avoids a warning about a possibly uninitialized variable
> when the function gets inlined into another one (which won't happen
> for this driver).

Huh?  I sent one where I could have done that but I deliberately didn't
because I wanted the uninitialized warning if I made a mistake.  It
sounds like you're working around a GCC bug...

regards,
dan carpenter
