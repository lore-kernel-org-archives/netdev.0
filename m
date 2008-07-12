From: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: linux-next: Tree for July 11
Date: Sat, 12 Jul 2008 12:31:49 -0700
Message-ID: <20080712123149.7e4ee346@infradead.org>
References: <20080711182557.9b24df1f.sfr@canb.auug.org.au>
	<200807122051.50909.rjw@sisk.pl>
	<19f34abd0807121221n75fd7bb8x24fa484239773201@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	"Stephen Rothwell" <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Kernel Testers List" <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Pekka Enberg" <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	"Jens Axboe" <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: "Vegard Nossum" <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <19f34abd0807121221n75fd7bb8x24fa484239773201-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 12 Jul 2008 21:21:38 +0200
"Vegard Nossum" <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> >  [<ffffffff8023d37f>] warn_on_slowpath+0x5f/0x80
> >  [<ffffffff80220030>] ? hpet_unregister_irq_handler+0x0/0x30
> >  [<ffffffff8022a8ae>] ? kmemcheck_mark_initialized+0xe/0x10
> >  [<ffffffff802b97fb>] ? kmemcheck_slab_alloc+0x2b/0x50
> >  [<ffffffff802b8610>] ? kmem_cache_alloc+0xc0/0x140
> >  [<ffffffff80291921>] ? mempool_alloc_slab+0x11/0x20
> >  [<ffffffff80291a8b>] ? mempool_alloc+0x5b/0x140
> >  [<ffffffff803575db>] blk_plug_device+0x9b/0xb0
> >  [<ffffffff80453d9f>] bitmap_startwrite+0xbf/0x1b0
> >  [<ffffffff802e87e4>] ? bio_alloc_bioset+0x54/0xb0
> >  [<ffffffffa004eafa>] make_request+0x39a/0x810 [raid1]
> >  [<ffffffff80291a8b>] ? mempool_alloc+0x5b/0x140
> >  [<ffffffff80291a8b>] ? mempool_alloc+0x5b/0x140
> >  [<ffffffff8035682d>] generic_make_request+0x17d/0x2b0
> >  [<ffffffff803581dc>] submit_bio+0x6c/0xf0
> Hm, even though there's kmemcheck in the stacktrace, I think it's
> unrelated. Probably it's just a call that returned and the addresses
> were left on the stack. 

more than "probably".. that's what the "?" in the trace is for ;)
