From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 5/7] slub: support for bulk free with SLUB freelists
Date: Mon, 28 Sep 2015 11:28:15 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1509281113400.30876@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon> <20150928122629.15409.69466.stgit@canyon> <alpine.DEB.2.20.1509281011250.30332@east.gentwo.org> <20150928175114.07e85114@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
    netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>,
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150928175114.07e85114@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Sep 2015, Jesper Dangaard Brouer wrote:

> > Do you really need separate parameters for freelist_head? If you just want
> > to deal with one object pass it as freelist_head and set cnt = 1?
>
> Yes, I need it.  We need to know both the head and tail of the list to
> splice it.

Ok so this is to avoid having to scan the list to its end? x is the end
of the list and freelist_head the beginning. That is weird.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
