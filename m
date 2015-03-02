From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch v2 1/3] mm: remove GFP_THISNODE
Date: Mon, 2 Mar 2015 09:46:33 -0600 (CST)
Message-ID: <alpine.DEB.2.11.1503020944200.5540@gentwo.org>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com> <54F469C1.9090601@suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Rientjes <rientjes@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@suse.de>,
	Pravin Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jrajahalme@nicira.com>,
	Li Zefan <lizefan@huawei.com>,
	Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org,
	cgroups@vger.kernel.org, dev@openvswitch.org
To: Vlastimil Babka <vbabka@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F469C1.9090601@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Mar 2015, Vlastimil Babka wrote:

> So it would be IMHO better for longer-term maintainability to have the
> relevant __GFP_THISNODE callers pass also __GFP_NO_KSWAPD to denote these
> opportunistic allocation attempts, instead of having this subtle semantic

You are thinking about an opportunistic allocation attempt in SLAB?

AFAICT SLAB allocations should trigger reclaim.
