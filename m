From: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: powerpc allmodconfig
Date: Thu, 16 Oct 2008 13:03:06 +0300
Message-ID: <20081016100306.GD23630@cs181140183.pp.htv.fi>
References: <20081015213337.a99a9595.akpm@linux-foundation.org> <s5h1vyhrsja.wl%tiwai@suse.de> <20081016073836.GB23630@cs181140183.pp.htv.fi> <s5hiqrtq8fc.wl%tiwai@suse.de> <20081016082157.GC23630@cs181140183.pp.htv.fi> <s5hod1lorpm.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	marek.vasut-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Mark Fasheh <mark.fasheh-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
To: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <s5hod1lorpm.wl%tiwai-l3A5Bk7waGM@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 16, 2008 at 10:43:33AM +0200, Takashi Iwai wrote:
> At Thu, 16 Oct 2008 11:21:57 +0300,
> Adrian Bunk wrote:
> > 
> > On Thu, Oct 16, 2008 at 09:57:11AM +0200, Takashi Iwai wrote:
> > > At Thu, 16 Oct 2008 10:38:36 +0300,
> > > Adrian Bunk wrote:
> > > > 
> > > > On Thu, Oct 16, 2008 at 07:57:29AM +0200, Takashi Iwai wrote:
> > > > > At Wed, 15 Oct 2008 21:33:37 -0700,
> > > > > Andrew Morton wrote:
> > > > > > 
> > > > > > sound/soc/soc-dapm.c:1029: warning: 'snd_soc_dapm_connect_input' is deprecated (declared at sound/soc/soc-dapm.c:1026)
> > > > > > sound/soc/soc-dapm.c:1029: warning: 'snd_soc_dapm_connect_input' is deprecated (declared at sound/soc/soc-dapm.c:1026)
> > > > > 
> > > > > These are definitions of deprecated interfaces.
> > > > > We can remove it in 2.6.29.  If we don't want to be conservative, it
> > > > > can be removed in 2.6.28, too.
> > > > >...
> > > > 
> > > > Since it's an in-kernel API there's no reason to keep it once there are 
> > > > no users left.
> > > 
> > > Right.  But, IMO, now is no suitable time.
> > > A thing like API removal should have been tested in linux-next, and we
> > > had plenty of time indeed for 2.6.28.
> > >...
> > 
> > A grep through the tree and one test compile that covers 
> > sound/soc/soc-dapm.c should be enough testing.
> > 
> > And having it then in -next once should be enough to discover if someone 
> > wrongly added a new user.
> 
> My point is the time for removal.  The API changes should have been
> done in the merge window, and it should have been tested *before* the
> merge window.
>...

My point is simply that compared to many other patches that weren't 
tested before the merge window, and that still get (for various reasons) 
into the tree, the removal of unused functions is extremely low-risk 
(assuming the patch creator knows what grep is and does a test compile 
of the changed code).

> thanks,
> 
> Takashi

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
