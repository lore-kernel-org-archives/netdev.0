From: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 0/6] fs: Scalability of sockets/pipes allocation/deallocation
 on SMP
Date: Wed, 26 Nov 2008 19:37:17 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0811261935330.31159@quilx.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu>
 <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net>
 <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com>
 <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com>
 <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <492DDB6A.8090806-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Nov 2008, Eric Dumazet wrote:

> The last point is about SLUB being hit hard, unless we
> use slub_min_order=3 at boot, or we use Christoph Lameter
> patch (struct file RCU optimizations)
> http://thread.gmane.org/gmane.linux.kernel/418615
>
> If we boot machine with slub_min_order=3, SLUB overhead disappears.


I'd rather not be that drastic. Did you try increasing slub_min_objects
instead? Try 40-100. If we find the right number then we should update
the tuning to make sure that it pickes the right slab page sizes.
