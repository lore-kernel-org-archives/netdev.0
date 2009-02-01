From: David Miller <davem@davemloft.net>
Subject: Re: gro: Fix handling of imprecisely split packets
Date: Sun, 01 Feb 2009 01:25:10 -0800 (PST)
Message-ID: <20090201.012510.119374504.davem@davemloft.net>
References: <20090201070117.GA2200@gondor.apana.org.au>
	<9929d2390901312349p2752f332pdb1ea4e523d184c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56658
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753373AbZBAJZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 04:25:14 -0500
In-Reply-To: <9929d2390901312349p2752f332pdb1ea4e523d184c3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 31 Jan 2009 23:49:49 -0800

> On Sat, Jan 31, 2009 at 11:01 PM, Herbert Xu
> <herbert@gondor.apana.org.au> wrote:
> > Hi Jeff:
> >
> > Please let me know if the ixgbe problems persist with this patch
> > against net-next.
> >
> > gro: Fix handling of imprecisely split packets
> >
> > The commit 89a1b249edcf9be884e71f92df84d48355c576aa (gro: Avoid
> > copying headers of unmerged packets) only worked for packets
> > which are either completely linear, completely non-linear, or
> > packets which exactly split at the boundary between headers and
> > payload.
> >
> > Anything else would cause bits in the header to go missing if
> > the packet is held by GRO.
> >
> > This may have broken drivers such as ixgbe.
> >
> > This patch fixes the places that assumed or only worked with
> > the above cases.
> >
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >
> 
> Thanks Herbert!
> 
> I have applied the patch and hopefully I will have more information to
> you soon.  At the very least, I should have updated information for
> you on Monday.

Meanwhile I'll toss Herbert's patch into net-next-2.6
