From: Pavel Machek <pavel@suse.cz>
Subject: Re: pm_register should die
Date: Mon, 12 Sep 2005 11:53:24 +0200
Message-ID: <20050912095323.GD27583@elf.ucw.cz>
References: <20050912093456.GA29205@elf.ucw.cz> <20050912024145.3c4298ec.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@zip.com.au, torvalds@osdl.org,
	vojtech@suse.cz, dwmw2@infradead.org, netdev@vger.kernel.org,
	benjamin_kong@ali.com.tw, dagb@cs.uit.no, jgarzik@pobox.com,
	davidm@snapgear.com, twoller@crystal.cirrus.com, alan@redhat.com,
	mm@caldera.de, scott@spiteful.org, jsimmons@transvirtual.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751287AbVILJxs@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050912024145.3c4298ec.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > +#ifdef CONFIG_OLD_PM
> >   	if (pm_send_all(PM_SUSPEND, (void *)3)) {
> 
> Can we not do this without ifdefs?
> 
> #define pm_send_all(foo, bar) 0

Okay, we probably can, but the ifdefs make very nice/easy markers
"this is going away". I'd prefer to actually delete all the code
inside those ifdefs...

I agree this patch can be improved... I hope I can get people to fix
those 13 occurences and be able to just drop everything in #ifdef
_OLD_PM.

								Pavel

-- 
if you have sharp zaurus hardware you don't need... you know my address
