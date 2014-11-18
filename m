From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 2/4] arch: Add lightweight memory barriers fast_rmb()
 and fast_wmb()
Date: Tue, 18 Nov 2014 11:39:27 +1100
Message-ID: <1416271167.18381.16.camel@kernel.crashing.org>
References: <20141117171005.22333.96544.stgit@ahduyck-server>
	 <20141117171812.22333.90395.stgit@ahduyck-server>
	 <1416254687.18381.3.camel@kernel.crashing.org> <546A5968.1090201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
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
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <546A5968.1090201@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-11-17 at 12:24 -0800, Alexander Duyck wrote:
> Yes and no.  So for example on ARM I used the dmb() operation, however
> I
> have to use the barrier at the system level instead of just the inner
> shared domain.  However on many other architectures they are just the
> same as the smp_* variants.
> 
> Basically the resultant code is somewhere between the smp and non-smp
> barriers in terms of what they cover.

There I don't quite follow you. You need to explain better especially in
the documentation because otherwise people will get it wrong...

If it's ordering in the coherent domain, I fail to see how a DMA agent
is different than another processor when it comes to barriers, so I fail
to see the difference with smp_*

I understand the MMIO vs. memory issue, we do have the same on powerpc,
but that other aspect eludes me.

Ben.
