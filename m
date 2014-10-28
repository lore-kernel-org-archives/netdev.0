From: Christoph Lameter <cl@linux.com>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Tue, 28 Oct 2014 14:46:22 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1410281445470.28700@gentwo.org>
References: <CAMEtUuwsUqd-U8ZSEXCB+a7cvLpbuRjPU2m0Ux84q6cxoWSx+g@mail.gmail.com> <1414029160.2094.8.camel@edumazet-glaptop2.roam.corp.google.com> <544873DF.1040403@gmail.com> <1414036276.2094.18.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141027213523.799da09c@redhat.com> <alpine.DEB.2.11.1410272129530.21936@gentwo.org> <CANn89i+U0=YrwoUSASejsS37EiXO7dKR25Vx04at3PqGA1EpHA@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-po-10v.sys.comcast.net ([96.114.154.169]:52864 "EHLO
	resqmta-po-10v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752798AbaJ1Tye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 15:54:34 -0400
In-Reply-To: <CANn89i+U0=YrwoUSASejsS37EiXO7dKR25Vx04at3PqGA1EpHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Oct 2014, Eric Dumazet wrote:

> Unfortunately, SLUB is more expensive than SLAB for many networking workloads.

hackbench performs better with SLUB.

> The cost of disabling interrupts is pure noise compared to cache line misses.
>
> SLUB has poor behavior compared to SLAB with alien caches,
> even with the side effect that 'struct page' is 64 bytes aligned
> instead of being 56 bytes with SLAB
>
> Note that I am not doing SLUB/SLAB tests every day, so it might be
> better nowadays.

Well we did some intensive work on these issues a couple of years ago.
