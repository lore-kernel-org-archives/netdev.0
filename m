From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] warning in SCTP
Date: Thu, 09 Nov 2006 16:30:13 -0800 (PST)
Message-ID: <20061109.163013.115933634.davem@davemloft.net>
References: <Pine.SOC.4.61.0611021119560.1919@math.ut.ee>
	<454A1836.9010709@hp.com>
	<1162492190.9660.28.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, mroos@linux.ee, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3232
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424299AbWKJAaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 19:30:22 -0500
To: sri@us.ibm.com
In-Reply-To: <1162492190.9660.28.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 02 Nov 2006 10:29:49 -0800

> On Thu, 2006-11-02 at 11:09 -0500, Vlad Yasevich wrote:
> > Meelis Roos wrote:
> > >> Actually, I'm backing this one out, it creates new warnings because
> > >> callers of this function pass in a "const" pointer.
> > > 
> > > Yes, it now seems it's not so simple. Marking it non-const there would
> > > mark the it non-const in the whole family of sctp_state_fn_t and I'm not
> > > sure that's the best thing to do. I guess the maintainer has better
> > > bases for deciding what to do about it.
> > > 
> > 
> > An alternate solution would be to make the digest a pointer, allocate
> > it in sctp_endpoint_init() and free it in sctp_endpoint_destroy().
> 
> I agree that this is a better solution.
> 
> Acked-by: Sridhar Samudrala <sri@us.ibm.com>

Applied to net-2.6.20, thanks everyone.
