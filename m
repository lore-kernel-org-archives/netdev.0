From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 1/2] mm: remove GFP_THISNODE
Date: Wed, 25 Feb 2015 18:56:43 -0600 (CST)
Message-ID: <alpine.DEB.2.11.1502251855330.14795@gentwo.org>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Pekka Enberg <penberg@kernel.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@suse.de>,
	Pravin Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jrajahalme@nicira.com>,
	Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org, dev@openvswitch.org
To: David Rientjes <rientjes@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2015, David Rientjes wrote:

> NOTE: this is not about __GFP_THISNODE, this is only about GFP_THISNODE.

Well but then its not removing it. You are replacing it with an inline
function.

> +
> +/*
> + * Construct gfp mask to allocate from a specific node but do not invoke reclaim
> + * or warn about failures.
> + */
> +static inline gfp_t gfp_exact_node(gfp_t flags)
> +{
> +	return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_WAIT;
> +}
>  #endif
