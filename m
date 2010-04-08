From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: hackbench regression due to commit 9dfc6e68bfe6e
Date: Thu, 8 Apr 2010 10:34:07 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1004081033420.6321@router.home>
References: <1270705153.8141.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
	alex.shi@intel.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ma, Ling" <ling.ma@intel.com>,
	"Chen, Tim C" <tim.c.chen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270705153.8141.58.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Apr 2010, Eric Dumazet wrote:

> I suspect NUMA is completely out of order on current kernel, or my
> Nehalem machine NUMA support is a joke
>
> # numactl --hardware
> available: 2 nodes (0-1)
> node 0 size: 3071 MB
> node 0 free: 2637 MB
> node 1 size: 3062 MB
> node 1 free: 2909 MB

How do the cpus map to the nodes? cpu 0 and 1 both on the same node?

> # ./try.sh
> Running with 50*40 (== 2000) tasks.
> Time: 16.865
> node0 results
> Running with 25*40 (== 1000) tasks.
> Time: 16.767
> node1 results
> Running with 25*40 (== 1000) tasks.
> Time: 16.564
> node0 on mem1 results
> Running with 25*40 (== 1000) tasks.
> Time: 16.814
> node1 on mem0 results
> Running with 25*40 (== 1000) tasks.
> Time: 16.896
>
>
>
