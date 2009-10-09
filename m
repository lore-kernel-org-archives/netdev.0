From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-10-08
Date: Fri, 9 Oct 2009 15:49:41 +0200
Message-ID: <200910091549.42933.mb@bu3sch.de>
References: <20091008223454.GB2798@tuxdriver.com> <200910090108.08838.mb@bu3sch.de> <20091009132317.GA22719@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091009132317.GA22719-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 09 October 2009 15:23:17 John W. Linville wrote:
> On Fri, Oct 09, 2009 at 01:08:06AM +0200, Michael Buesch wrote:
> > On Friday 09 October 2009 00:34:54 John W. Linville wrote:
> > > Albert Herranz (1):
> > >       b43: do not stack-allocate pio rx/tx header and tail buffers
> > 
> > Come on, this is _not_ funny anymore. I did _not_ ack this patch, because I do _not_ like it.
> > I was planning to do a better solution, but I didn't have the time, yet.
> > Can you _please_ either:
> > - Wait for my ack before you apply random b43 patches
> > or
> > - Remove me from MAINTAINERS
> 
> Michael,
> 
> After Albert posted his first version of the patch, you said:
> 
> "Just embed it into struct b43_wl (surround it by #ifdef CONFIG_B43_PIO). No need
> to kzalloc then and it saves some memory.
> You also need to alloc 4 bytes for the tail buffer (that currently is on the stack, too)."
> 
> AFAICT he complied with that request when he posted the second version.

Yeah, but I don't like the result for reasons I already said.
I'll send another patch that moves the structure back and cleans up stuff later.

> Since the patch seemed fine otherwise, I applied it; and since it is
> a fix I sent it on for 2.6.32.

Well, we once had a rule that not everything that remotely looks like a fix should
go in, after the merge window closed. AFAIR this rule was made by Linus and I think
it does make sense, in some way.
This touched a lot of crap for fixing something that
a) is not a bug on any officially supported device
b) just triggers a harmless warning on devices that virtually nobody owns and/or
  runs linux on (Nintendo Wii), if some specific debugging option is enabled.
So I don't buy the argument that suddenly millions over millions of bugreports will
flood the lists, if we didn't apply this.

I think we should be more careful about what patches are applied. Otherwise I'm sure
Linus will start to complain about crap pull requests with huge modifications again.
And he'd be right.

> P.S.  Please understand that while some driver maintainers want to
> ack every patch, others see that as a burden and get annoyed with me
> if I don't apply reasonable patches without bothering them.  It can
> be a bit difficult these things...

Yeah, however I think I _do_ respond very quickly to any patch that matters
with either an ack or comments.
I think it's always a good idea to wait for a final ack on a patch that
a maintainer complained about. If nobody complained, well that's a different thing.
I'd still prefer a review delay of at least 24hours for those, to ensure somebody
knowing the code has a chance to look at them.

-- 
Greetings, Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
