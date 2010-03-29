From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Mon, 29 Mar 2010 23:43:21 +0200
Message-ID: <20100329214321.GI20695@one.firstfloor.org>
References: <87tysccjrn.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003220916170.15360@router.home> <20100322163609.GZ20695@one.firstfloor.org> <alpine.DEB.2.00.1003221146260.17230@router.home> <877hp4i76d.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003221300180.17230@router.home> <20100322185310.GA20695@one.firstfloor.org> <alpine.DEB.2.00.1003261231410.30253@router.home> <20100327131138.GD20695@one.firstfloor.org> <alpine.DEB.2.00.1003290952410.14606@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58308 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101Ab0C2Vn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 17:43:26 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003290952410.14606@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 10:00:57AM -0500, Christoph Lameter wrote:
> On Sat, 27 Mar 2010, Andi Kleen wrote:
> 
> > On Fri, Mar 26, 2010 at 12:33:07PM -0500, Christoph Lameter wrote:
> > > Here is a pgm.7 manpage describing how the socket API could look like for
> > > a PGM implementation.
> > >
> > > I dumped the RM_* based socket options from the other OS since most of the
> > > options were unusable.
> >
> > I did a quick read and the manpage/interface seem reasonable to me.
> 
> Thanks. I will then proceed to get a patch out that implements the
> network environment. Then we can plug the openpgm logic in there.

You might still need some reviewing from network maintainers.

> 
> > You changed the parameter struct fields to lower case. While
> > that looks definitely more Linuxy than before does it mean programs
> > have to #ifdef this? It might be good idea to have at least some
> > optional compat header that #defines.
> 
> The socket API will be completely different. The basic handling of the
> sockets is the same (binding, listening, connecting). There is no way of
> mapping M$ socket options to Linux socket options with the approach that
> I proposed in the manpage. The stats structure is different too since some
> key elements were missing.

Ok.

> 
> What users are there of the M$ api? I have seen vendors supplying their
> own pgm implementation (guess due to bit rot in the old M$
> implementation).

I don't know, it was just a general consideration.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
