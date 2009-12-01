From: Jesper Nilsson <Jesper.Nilsson@axis.com>
Subject: Re: [PATCH] Update embedded copy of ethtool.h from kernel 2.6.30
Date: Tue, 1 Dec 2009 16:42:46 +0100
Message-ID: <20091201154246.GH5694@axis.com>
References: <20091201151750.GG5694@axis.com> <1259680878.2831.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:60976 "EHLO
	miranda.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbZLAPmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 10:42:51 -0500
Content-Disposition: inline
In-Reply-To: <1259680878.2831.3.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2009 at 04:21:18PM +0100, Ben Hutchings wrote:
> On Tue, 2009-12-01 at 16:17 +0100, Jesper Nilsson wrote:
> > Commit 0c09c1a49cc7b819b33566a49d9901f7cfdd6889 in the Linux kernel
> > added a new field mdio_support inside the struct ethtool_cmd,
> > changing the struct size for architectures that does not pad structs.
> > (for example the CRIS architecture)
> 
> CRIS has no alignment requirements?!  Wow.

Yep, we don't even have the choice of adding padding inside structs. :-(

>  Sorry for changing the
> structure, then.

We're used to tripping over this kind of thing. :-)

> > This size mismatch lead to the ethtool_cmd struct being written
> > as 44 bytes in the kernel, but only 43 bytes allocated on stack,
> > overwriting one byte in the stack frame.
> > 
> > Update the ethtool copy of the definition to match the 2.6.30 kernel.
> [...]
> 
> This has already been done.

Ah? Could someone point me to the correct git-tree for ethtool then?
I've been using http://www.kernel.org/pub/scm/network/ethtool/ethtool.git
which still has this problem...

> Ben.

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com
