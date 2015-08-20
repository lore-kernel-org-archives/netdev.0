From: David Rientjes <rientjes@google.com>
Subject: RE: [Intel-wired-lan] [Patch V3 5/9] i40e: Use numa_mem_id() to
 better	support memoryless node
Date: Wed, 19 Aug 2015 17:18:15 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1508191717450.30666@chino.kir.corp.google.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com> <1439781546-7217-6-git-send-email-jiang.liu@linux.intel.com> <4197C471DCF8714FBA1FE32565271C148FFFF4D3@ORSMSX103.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jiang Liu <jiang.liu@linux.intel.com>,
    Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>,
    Mike Galbraith <umgwanakikbuti@gmail.com>,
    Peter Zijlstra <peterz@infradead.org>,
    "Wysocki, Rafael J" <rafael.j.wysocki@intel.com>,
    Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>,
    "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
    "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
    "Nelson, Shannon" <shannon.nelson@intel.com>,
    "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
    "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
    "Vick, Matthew" <matthew.vick@intel.com>,
    "Ronciak, John" <john.ronciak@intel.com>,
    "Williams, Mitch A" <mitch.a.williams@intel.com>,
    "Luck, Tony" <tony.luck@intel.com>,
    "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
    "x86@kernel.org" <x86@kernel.org>,
To: "Patil, Kiran" <kiran.patil@intel.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4197C471DCF8714FBA1FE32565271C148FFFF4D3@ORSMSX103.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Aug 2015, Patil, Kiran wrote:

> Acked-by: Kiran Patil <kiran.patil@intel.com>

Where's the call to preempt_disable() to prevent kernels with preemption 
from making numa_node_id() invalid during this iteration?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
