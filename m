From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: Re: [RFC Patch V1 15/30] mm, igb: Use cpu_to_mem()/numa_mem_id()
 to support memoryless node
Date: Wed, 23 Jul 2014 11:20:20 +0800
Message-ID: <53CF29F4.7040700@linux.intel.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-16-git-send-email-jiang.liu@linux.intel.com> <20140721174218.GD4156@linux.vnet.ibm.com> <CAKgT0UdZdbduP-=R7uRCxJVxt1yCDoHpnercnDoyrCbWNtx=6Q@mail.gmail.com> <20140721210900.GI4156@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@suse.de>,
 David Rientjes <rientjes@google.com>,
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
 Linux NICS <linux.nics@intel.com>,
 Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org,
 linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org,
 e1000-devel@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20140721210900.GI4156@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi Nishanth and Alexander,
	Thanks for review, will update the comments
in next version.
Regards!
Gerry

On 2014/7/22 5:09, Nishanth Aravamudan wrote:
> On 21.07.2014 [12:53:33 -0700], Alexander Duyck wrote:
>> I do agree the description should probably be changed.  There shouldn't be
>> any panics involved, only a performance impact as it will be reallocating
>> always if it is on a node with no memory.
> 
> Yep, thanks for the review.
> 
>> My intention on this was to make certain that the memory used is from the
>> closest node possible.  As such I believe this change likely honours that.
> 
> Absolutely, just wanted to make it explicit that it's not a functional
> fix, just a performance fix (presuming this shows up at all on systems
> that have memoryless NUMA nodes).
> 
> I'd suggest an update to the comments, as well.
> 
> Thanks,
> Nish
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
