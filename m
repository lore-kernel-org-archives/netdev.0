From: Paul Mackerras <paulus@samba.org>
Subject: Re: iptables very slow after commit
	784544739a25c30637397ace5489eeb6e15d7d49
Date: Sun, 12 Apr 2009 21:34:27 +1000
Message-ID: <18913.53699.544083.320542@cargo.ozlabs.ibm.com>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com>
	<20090410095246.4fdccb56@s6510>
	<20090410.182507.140306636.davem@davemloft.net>
	<alpine.LFD.2.00.0904101828490.4583@localhost.localdomain>
	<20090411041533.GB6822@linux.vnet.ibm.com>
	<20090411070854.GC11799@elte.hu>
	<20090411174801.GG6822@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Lai Jiangshan <laijs@cn.fujitsu.com>, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090411174801.GG6822@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney writes:

> If the generic implementation is needed only on !SMP systems, that
> could work.  The architectures I would be worried about include
> powerpc and ia64, which I believe support 32-bit SMP builds.

32-bit powerpc doesn't have 64-bit atomic operations and does support
SMP.

What about ARM?  I thought they had 32-bit SMP these days as well.

Paul.
