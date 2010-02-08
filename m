From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [Bug #15196] kmem_cache_create: duplicate cache ccid2_h
Date: Mon, 8 Feb 2010 12:04:27 +0100
Message-ID: <201002081204.28039.rjw@sisk.pl>
References: <4Ht3jFrT7uE.A.JI.-nzbLB@chimera> <445R0ey9hAI.A.tNB.XozbLB@chimera> <20100208071515.GA6473@fancy-poultry.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Heinz Diehl <htd-HjJ2MNWy62to6+H+lsi3Gti2O/JbrIOy@public.gmane.org>,
	Xiaotian Feng <xtfeng-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100208071515.GA6473-HjJ2MNWy62to6+H+lsi3Gti2O/JbrIOy@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 08 February 2010, Heinz Diehl wrote:
> On 08.02.2010, Rafael J. Wysocki wrote: 
> 
> > This message has been generated automatically as a part of a summary report
> > of recent regressions.
> > 
> > The following bug entry is on the current list of known regressions
> > from 2.6.32.  Please verify if it still should be listed and let the tracking team
> > know (either way).
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15196
> > Subject		: kmem_cache_create: duplicate cache ccid2_h
> > Submitter	: Heinz Diehl <htd-HjJ2MNWy62to6+H+lsi3Gti2O/JbrIOy@public.gmane.org>
> > Date		: 2010-01-30 18:33 (9 days old)
> > References	: http://marc.info/?l=linux-kernel&m=126487640324942&w=4
> > Handled-By	: Xiaotian Feng <xtfeng-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Patch		: http://patchwork.kernel.org/patch/77601/
> 
> Yes, it's still present in -rc7.

Hmm.  The bug is in net/dccp/ccid.c, so it looks like something for the
networking guys to merge.

Any chance to send a singed-off version of the patch do David?

Rafael
