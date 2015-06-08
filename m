From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH] slub: RFC: Improving SLUB performance with 38% on
 NO-PREEMPT
Date: Mon, 8 Jun 2015 04:39:38 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1506080438570.10781@east.gentwo.org>
References: <20150604103159.4744.75870.stgit@ivy> <1433471877.1895.51.camel@edumazet-glaptop2.roam.corp.google.com> <20150608112359.04a3750e@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>,
    Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
    netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150608112359.04a3750e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 8 Jun 2015, Jesper Dangaard Brouer wrote:

> My real question is if disabling local interrupts is enough to avoid this?

Yes the initial release of slub used interrupt disable in the fast paths.

> And, does local irq disabling also stop preemption?

Of course.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
