From: David Miller <davem@davemloft.net>
Subject: Re: iptables very slow after commit
 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sun, 12 Apr 2009 18:13:30 -0700 (PDT)
Message-ID: <20090412.181330.23529546.davem@davemloft.net>
References: <20090411174801.GG6822@linux.vnet.ibm.com>
	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>
	<20090412173108.GO6822@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090412173108.GO6822@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Sun, 12 Apr 2009 10:31:08 -0700

> On Sun, Apr 12, 2009 at 09:34:27PM +1000, Paul Mackerras wrote:
>> Paul E. McKenney writes:
>> 
>> > If the generic implementation is needed only on !SMP systems, that
>> > could work.  The architectures I would be worried about include
>> > powerpc and ia64, which I believe support 32-bit SMP builds.
>> 
>> 32-bit powerpc doesn't have 64-bit atomic operations and does support
>> SMP.
>> 
>> What about ARM?  I thought they had 32-bit SMP these days as well.
> 
> Some of Steve Hemminger's recent suggestions in this thread seem to me
> to avoid this whole issue nicely.  But we will see!  ;-)

I hope so.

Eventually it seems that all of the older 32-bit SMP platforms
will be run under a bus having to execute some many "efficient"
primitives using the "hash table of spinlocks" scheme for
synchronization.
