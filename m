From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: iptables very slow after commit
	784544739a25c30637397ace5489eeb6e15d7d49
Date: Sun, 12 Apr 2009 10:31:08 -0700
Message-ID: <20090412173108.GO6822@linux.vnet.ibm.com>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com> <20090410095246.4fdccb56@s6510> <20090410.182507.140306636.davem@davemloft.net> <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain> <20090411041533.GB6822@linux.vnet.ibm.com> <20090411070854.GC11799@elte.hu> <20090411174801.GG6822@linux.vnet.ibm.com> <18913.53699.544083.320542@cargo.ozlabs.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Lai Jiangshan <laijs@cn.fujitsu.com>, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:57398 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167AbZDLRbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Apr 2009 13:31:06 -0400
Content-Disposition: inline
In-Reply-To: <18913.53699.544083.320542@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 12, 2009 at 09:34:27PM +1000, Paul Mackerras wrote:
> Paul E. McKenney writes:
> 
> > If the generic implementation is needed only on !SMP systems, that
> > could work.  The architectures I would be worried about include
> > powerpc and ia64, which I believe support 32-bit SMP builds.
> 
> 32-bit powerpc doesn't have 64-bit atomic operations and does support
> SMP.
> 
> What about ARM?  I thought they had 32-bit SMP these days as well.

Some of Steve Hemminger's recent suggestions in this thread seem to me
to avoid this whole issue nicely.  But we will see!  ;-)

							Thanx, Paul
