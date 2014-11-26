From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v5 2/4] arch: Add lightweight memory barriers dma_rmb()
 and dma_wmb()
Date: Wed, 26 Nov 2014 16:04:56 +0000
Message-ID: <20141126160456.GJ14866@arm.com>
References: <20141119012205.9563.95544.stgit@ahduyck-server>
 <20141119012400.9563.21117.stgit@ahduyck-server>
 <20141125140130.GC8541@arm.com>
 <5474ADB4.5070200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mathieu.desnoyers@polymtl.ca" <mathieu.desnoyers@polymtl.ca>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
	"mingo@kernel.org" <mingo@kernel.org>,
	"mikey@neuling.org" <mikey@neuling.org>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"matthew.vick@intel.com" <matthew.vick@intel.com>,
	"geert@linux-m68k.org" <geert@linux-m68k.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"nic_swsd@realtek.com" <nic_
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5474ADB4.5070200@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2014 at 04:26:28PM +0000, Alexander Duyck wrote:
> On 11/25/2014 06:01 AM, Will Deacon wrote:
> > If we ever see platforms using Linux/dma_alloc_coherent with devices
> > mastering from a different outer-shareable domain that the one containing
> > the CPUs, then we'll need to revisit this.
> 
> Would we just need a system wide memory barrier in that case instead of 
> an outer shareable memory barrier, or would we need to look as something 
> like a sync barrier?

I think dmb(sy) would do the trick, but let's cross that bridge if/when we
have to.

Will
