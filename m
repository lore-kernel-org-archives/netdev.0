From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
Date: Fri, 1 May 2009 11:14:32 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0905011114140.18324@qirst.com>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils> <20090430132544.GB21997@csn.ul.ie> <Pine.LNX.4.64.0905011202530.8513@blonde.anvils> <20090501140015.GA27831@csn.ul.ie> <alpine.DEB.1.10.0905010958090.18324@qirst.com>
 <20090501150933.GE27831@csn.ul.ie>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>,
    Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>,
    netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20090501150933.GE27831@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, 1 May 2009, Mel Gorman wrote:

> But IIRC, the vmemmap code depends on architecture-specific help from
> vmemmap_populate() to place the map in the right place and it's not universally
> available. It's likely that similar would be needed to support large
> hash tables. I think the networking guys would need to be fairly sure
> the larger table would make a big difference before tackling the
> problem.

The same function could be used. Fallback to vmap is always possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
