From: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Subject: Re: kernel 3.5.2/amd64: iwlwifi 0000:03:00.0: failed to allocate pci memory
Date: Mon, 10 Sep 2012 08:34:31 -0700
Message-ID: <20120910153431.GD5053@merlins.org>
References: <20120908161038.GF3347@merlins.org> <1347122927.1234.849.camel@edumazet-glaptop> <20120904003014.GB6287@merlins.org> <20120908170128.GK3347@merlins.org> <1347130641.11167.0.camel@jlt4.sipsolutions.net> <1347272641.4272.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-q7rQbLoQdy39qxiX1TGQuw@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1347272641.4272.1.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 10, 2012 at 12:24:01PM +0200, Johannes Berg wrote:
> On Sat, 2012-09-08 at 20:57 +0200, Johannes Berg wrote:
> 
> > > [856806.497959]  [<ffffffff810cf54c>] warn_alloc_failed+0x117/0x12c
> > > [856806.497963]  [<ffffffff810d23af>] __alloc_pages_nodemask+0x6e3/0x792
> > > [856806.497969]  [<ffffffff812b7f41>] ? pfn_to_dma_pte+0x116/0x15e
> > > [856806.497976]  [<ffffffff810ff58b>] alloc_pages_current+0xcd/0xee
> > > [856806.497979]  [<ffffffff810cecca>] __get_free_pages+0x9/0x45
> > > [856806.497982]  [<ffffffff812ba67d>] intel_alloc_coherent+0x84/0xe7
> > > [856806.497986]  [<ffffffff81085cf8>] ? arch_local_irq_save+0x15/0x1b
> > > [856806.497999]  [<ffffffffa0b84afc>] iwl_ucode_callback+0xa49/0xc0d [iwlwifi]
> > 
> > Yes, unfortunately we need a whole bunch of contiguous memory to load
> > the firmware.
> > 
> > > Any ideas?
> > 
> > Nothing we can do from the driver side, I'm afraid.
> 
> Turns out I was wrong. Here's a patch you can test. Note that we still
> need a lot of DMA-coherent memory for other things, but at least for the
> firmware image we don't.

Thanks for that, I'll try it out and report back if I have other problems
(it's hard to prove that it worked since I don't have the fragmented memory
right away).

Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
