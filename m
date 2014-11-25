From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH v5 2/4] arch: Add lightweight memory barriers dma_rmb()
 and dma_wmb()
Date: Wed, 26 Nov 2014 10:15:28 +1100
Message-ID: <1416957328.5089.17.camel@kernel.crashing.org>
References: <20141119012205.9563.95544.stgit@ahduyck-server>
	 <20141119012400.9563.21117.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mathieu.desnoyers@polymtl.ca,
	peterz@infradead.org, heiko.carstens@de.ibm.com, mingo@kernel.org,
	mikey@neuling.org, linux@arm.linux.org.uk,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	geert@linux-m68k.org, jeffrey.t.kirsher@intel.com,
	romieu@fr.zoreil.com, paulmck@linux.vnet.ibm.com,
	nic_swsd@realtek.com, will.deacon@arm.com, michael@ellerman.id.au,
	tony.luck@intel.com, torvalds@linux-foundation.org,
	oleg@redhat.com, schwidefsky@de.ibm.com, fweisbec@gmail.com,
	davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20141119012400.9563.21117.stgit@ahduyck-server>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-11-18 at 17:24 -0800, Alexander Duyck wrote:
> There are a number of situations where the mandatory barriers rmb() and
> wmb() are used to order memory/memory operations in the device drivers
> and those barriers are much heavier than they actually need to be.  For
> example in the case of PowerPC wmb() calls the heavy-weight sync
> instruction when for coherent memory operations all that is really needed
> is an lsync or eieio instruction.
>  .../...

For powerpc:

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
