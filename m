From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [NET]: Lockless loopback patch (version 2).
Date: Mon, 21 Jun 2004 08:09:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SGI.4.56.0406210807200.1239015@neteng.engr.sgi.com>
References: <200406210510.i5L5A340018849@hera.kernel.org>
 <20040621035702.6114bdbe.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040621035702.6114bdbe.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Jun 2004, Andrew Morton wrote:

> Linux Kernel Mailing List <linux-kernel@vger.kernel.org> wrote:
> >
> > 	[NET]: Lockless loopback patch (version 2).
>
> The loopback_stats handling looks wrong:
>
> ....
> each get_cpu_ptr() does get_cpu(), which increments preempt_count().  But
> there is only a single put_cpu_ptr() in there.
>
>
> Still, I don't see why we need to use alloc_percpu() - why not
> statically allocate it?
>
> This compiles, but does need runtime testing.

Thanks, Andrew. I'll do some basic testing of this change and
post results (probably by tomorrow.)

--

Arthur
