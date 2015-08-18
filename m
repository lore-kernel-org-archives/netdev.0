From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [Patch V3 4/9] openvswitch: Replace cpu_to_node() with
 cpu_to_mem() to support memoryless node
Date: Mon, 17 Aug 2015 17:14:08 -0700
Message-ID: <CALnjE+pTMo2E2CSswzbSeTPONvUQ8d_+Z1UbGVKMEZcSCjtA=A@mail.gmail.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
	<1439781546-7217-5-git-send-email-jiang.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>,
	David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
	Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org,
	linux-hotplug@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	x86@kernel.org, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1439781546-7217-5-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 16, 2015 at 8:19 PM, Jiang Liu <jiang.liu@linux.intel.com> wrote:
> Function ovs_flow_stats_update() allocates memory with __GFP_THISNODE
> flag set, which may cause permanent memory allocation failure on
> memoryless node. So replace cpu_to_node() with cpu_to_mem() to better
> support memoryless node. For node with memory, cpu_to_mem() is the same
> as cpu_to_node().
>
> This change only affects performance and shouldn't affect functionality.
>
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
