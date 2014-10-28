From: Christoph Lameter <cl@linux.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Mon, 27 Oct 2014 21:30:24 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1410272129530.21936@gentwo.org>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com> <1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com> <544873DF.1040403@gmail.com> <1414036276.2094.18.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141027213523.799da09c@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-03v.sys.comcast.net ([69.252.207.35]:55593 "EHLO
	resqmta-ch2-03v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751829AbaJ1Cio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 22:38:44 -0400
In-Reply-To: <20141027213523.799da09c@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Oct 2014, Jesper Dangaard Brouer wrote:

> > Same could be done with some kmem_cache_alloc() : SLAB uses hard irq
> > masking while some caches are never used from hard irq context.
>
> Sounds interesting.

SLUB does not disable interrupts in the fast paths.
