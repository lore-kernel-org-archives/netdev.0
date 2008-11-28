From: Marcin Slusarz <marcin.slusarz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: option: oops on unload (2.6.27.4)
Date: Fri, 28 Nov 2008 23:01:43 +0100
Message-ID: <20081128220142.GC6750@joi>
References: <20081128213254.GB6750@joi> <20081128215021.GA25391@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081128215021.GA25391-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 28, 2008 at 01:50:21PM -0800, Greg KH wrote:
> On Fri, Nov 28, 2008 at 10:32:59PM +0100, Marcin Slusarz wrote:
> > It's not new bug - I've seen this oops many times but on much older
> > kernels (2.6.18, probably on 2.6.24 too).
> > 
> > I tried to rmmod it (and all usb modules) because sometimes it helps when
> > modem disconnects and can't connect again.
> > 
> > [25350.138850] BUG: unable to handle kernel paging request at e0857fb4
> > [25350.138866] IP: [<e0a22e80>] :usbcore:unlink1+0xab/0xb9
> > [25350.138921] *pde = 1f80f067 *pte = 00000000 
> > [25350.138934] Oops: 0000 [#1] PREEMPT SMP 
> > [25350.138945] Modules linked in: r128 drm ipt_REDIRECT ipt_MASQUERADE xt_tcpudp xt_multiport iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack iptable_filter ip_tables ppp_deflate zlib_deflate zlib_inflate bsd_comp ppp_async crc_ccitt ppp_generic slhc ipt_REJECT x_tables loop option usbserial snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_timer snd 8139cp i2c_i801 floppy 8139too 3c59x psmouse intel_agp soundcore snd_page_alloc sg mii usbcore agpgart i2c_core sr_mod evdev dcdbas cdrom [last unloaded: uhci_hcd]
> > [25350.139052] 
> > [25350.139059] Pid: 2807, comm: pppd Not tainted (2.6.27.4 #5)
> > [25350.139065] EIP: 0060:[<e0a22e80>] EFLAGS: 00010286 CPU: 0
> > [25350.139088] EIP is at unlink1+0xab/0xb9 [usbcore]
> 
> Yes, I've seen this before, what module are you unloading, uhci-hcd or
> the option module?

I don't know :| I invoked "rmmod option usbserial uhci_hcd usbcore"
 
> Can you try 2.6.28-rc6? 

Yes. I'll check it in few days.

> I think we have fixed a few things in this area
> that should resolve this, if it is the uhci-hcd driver you are
> unloading.

Marcin
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
