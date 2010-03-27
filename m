From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Sat, 27 Mar 2010 14:11:39 +0100
Message-ID: <20100327131138.GD20695@one.firstfloor.org>
References: <alpine.DEB.2.00.1003181245050.23010@router.home> <87tysccjrn.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003220916170.15360@router.home> <20100322163609.GZ20695@one.firstfloor.org> <alpine.DEB.2.00.1003221146260.17230@router.home> <877hp4i76d.fsf@basil.nowhere.org> <alpine.DEB.2.00.1003221300180.17230@router.home> <20100322185310.GA20695@one.firstfloor.org> <alpine.DEB.2.00.1003261231410.30253@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:53296 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931Ab0C0NLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 09:11:43 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003261231410.30253@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 26, 2010 at 12:33:07PM -0500, Christoph Lameter wrote:
> Here is a pgm.7 manpage describing how the socket API could look like for
> a PGM implementation.
> 
> I dumped the RM_* based socket options from the other OS since most of the
> options were unusable.

I did a quick read and the manpage/interface seem reasonable to me.

You changed the parameter struct fields to lower case. While
that looks definitely more Linuxy than before does it mean programs
have to #ifdef this? It might be good idea to have at least some
optional compat header that #defines.

-Andi
