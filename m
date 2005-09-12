From: Andrew Morton <akpm@osdl.org>
Subject: Re: pm_register should die
Date: Mon, 12 Sep 2005 03:03:06 -0700
Message-ID: <20050912030306.42a73f62.akpm@osdl.org>
References: <20050912093456.GA29205@elf.ucw.cz>
	<20050912024145.3c4298ec.akpm@osdl.org>
	<20050912095323.GD27583@elf.ucw.cz>
	<20050912095532.GA27763@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@osdl.org, vojtech@suse.cz,
	dwmw2@infradead.org, netdev@vger.kernel.org,
	benjamin_kong@ali.com.tw, dagb@cs.uit.no, jgarzik@pobox.com,
	davidm@snapgear.com, twoller@crystal.cirrus.com, alan@redhat.com,
	mm@caldera.de, scott@spiteful.org, jsimmons@transvirtual.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750701AbVILKHi@vger.kernel.org>
To: Pavel Machek <pavel@suse.cz>
In-Reply-To: <20050912095532.GA27763@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek <pavel@suse.cz> wrote:
>
> Hi!
> 
> > > > +#ifdef CONFIG_OLD_PM
> > > >   	if (pm_send_all(PM_SUSPEND, (void *)3)) {
> > > 
> > > Can we not do this without ifdefs?
> > > 
> > > #define pm_send_all(foo, bar) 0
> > 
> > Okay, we probably can, but the ifdefs make very nice/easy markers
> > "this is going away". I'd prefer to actually delete all the code
> > inside those ifdefs...
> > 
> > I agree this patch can be improved... I hope I can get people to fix
> > those 13 occurences and be able to just drop everything in #ifdef
> > _OLD_PM.
> 
> There's another reason: they are ifdef-ed out so that you don't see
> "obsolete function called" warning. Breaking the function and hiding
> the warning at same time would seem like a wrong thing to do. If
> someone does pm_send_all in his code, we want him to see the warning.
> 

Fair enough.
