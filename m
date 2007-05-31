From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Please pull 'libertas' branch of wireless-2.6
Date: Thu, 31 May 2007 17:13:17 -0400
Message-ID: <1180645997.18078.8.camel@xo-28-0B-88.localdomain>
References: <20070529183347.GD3496@tuxdriver.com>
	 <465D8538.8070507@garzik.org>
	 <1180538928.17163.10.camel@xo-28-0B-88.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1180538928.17163.10.camel-Hs+VJEcF3DojzQS9c19i8iZi+YwRKgec@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-30 at 11:28 -0400, Dan Williams wrote:
> On Wed, 2007-05-30 at 10:07 -0400, Jeff Garzik wrote:
> > John W. Linville wrote:
> > > Lots of stuff here...probably best for 2.6.23...
> > 
> > Is this best for Linux users... or just easy for developers?
> > 
> > Won't putting off all these fixes until 2.6.23 leave the driver released 
> > in 2.6.22 in shoddy shape?
> 
> Not really; it more or less works there.  What's gone on since then is
> general driver cleanup (Christoph's comments and more), splitting the
> driver so that other bus types can use it (SDIO for example once
> Pierre's SDIO patches get upstream), wireless extensions fixes, etc.
> 
> > libertas is upstream now, so we cannot pretend that the driver is 
> > completely independent from upstream release cycles and maintenance.
> 
> True, but some of the stuff in here I didn't think would be suitable
> during an -rc cycle, for example the driver splitting and the cleanups
> that don't impact function at all, but are good to do nonetheless.
> 
> > libertas fixes should go upstream immediately, since we are in a bugfix 
> > cycle, and since libertas (from upstream perspective) is about to make 
> > its big debut on the world stage.
> 
> If you think all the bits from this should just go to 2.6.22, that's
> fine with me.  But I don't feel comfortable making that call given what
> I thought were the constraints on pushing changes through during an rc
> cycle.  When the merge window was open, we backported critical bug fixes
> and necessary merge-requirement cleanups to the code in linville's tree,
> but avoided changes that didn't impact function.

Any response on these points yet?  I've got yet more cleanups and a few
other things queued in libertas-2.6 but I'd like to see where this
discussion goes before sending a pull request for the new bits.

Dan

> Dan
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
