From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 20:50:52 +0100
Message-ID: <873a31cvvn.fsf@basil.nowhere.org>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu>
	<4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu>
	<4B3103B4.4070708@gmail.com>
	<f73f7ab80912222215i39ba865dv95764f95fd57bd96@mail.gmail.com>
	<4B3254B4.2080602@gmail.com> <20091223192808.GA30700@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Kyle Moffett <kyle@moffetthome.net>,
	Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20091223192808.GA30700@ovro.caltech.edu> (Ira W. Snyder's message of "Wed, 23 Dec 2009 11:28:08 -0800")
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Ira W. Snyder" <iws@ovro.caltech.edu> writes:

> (You'll quickly find that you must use DMA to transfer data across PCI.
> AFAIK, CPU's cannot do burst accesses to the PCI bus. I get a 10+ times

AFAIK that's what write-combining on x86 does. DMA has other
advantages of course.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
