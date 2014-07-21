From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 15/30] mm, igb: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
Date: Mon, 21 Jul 2014 14:09:00 -0700
Message-ID: <20140721210900.GI4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
 <1405064267-11678-16-git-send-email-jiang.liu@linux.intel.com>
 <20140721174218.GD4156@linux.vnet.ibm.com>
 <CAKgT0UdZdbduP-=R7uRCxJVxt1yCDoHpnercnDoyrCbWNtx=6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiang Liu <jiang.liu@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>,
        Mike Galbraith <umgwanakikbuti@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Bruce Allan <bruce.w.allan@intel.com>,
        Carolyn Wyborny <carolyn.wyborny@intel.com>,
        Don Skidmore <donald.c.skidmore@intel.com>,
        Greg Rose <gregory.v.rose@intel.com>,
        Alex Duyck <alexander.h.duyck@intel.com>,
        John Ronciak <john.ronciak@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        Linux NICS <linux.nics@intel.com>, Tony Luck <tony.luck@intel.com>,
        linux-mm@kvack.org, linux-hotplug@
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <CAKgT0UdZdbduP-=R7uRCxJVxt1yCDoHpnercnDoyrCbWNtx=6Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 21.07.2014 [12:53:33 -0700], Alexander Duyck wrote:
> I do agree the description should probably be changed.  There shouldn't be
> any panics involved, only a performance impact as it will be reallocating
> always if it is on a node with no memory.

Yep, thanks for the review.

> My intention on this was to make certain that the memory used is from the
> closest node possible.  As such I believe this change likely honours that.

Absolutely, just wanted to make it explicit that it's not a functional
fix, just a performance fix (presuming this shows up at all on systems
that have memoryless NUMA nodes).

I'd suggest an update to the comments, as well.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
