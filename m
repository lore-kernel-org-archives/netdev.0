From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'libertas' branch of wireless-2.6
Date: Thu, 31 May 2007 17:16:05 -0400
Message-ID: <20070531211605.GA30161@tuxdriver.com>
References: <20070529183347.GD3496@tuxdriver.com> <465D8538.8070507@garzik.org> <1180538928.17163.10.camel@xo-28-0B-88.localdomain> <1180645997.18078.8.camel@xo-28-0B-88.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4606 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197AbXEaWYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 18:24:40 -0400
Content-Disposition: inline
In-Reply-To: <1180645997.18078.8.camel@xo-28-0B-88.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 31, 2007 at 05:13:17PM -0400, Dan Williams wrote:
> On Wed, 2007-05-30 at 11:28 -0400, Dan Williams wrote:
> > On Wed, 2007-05-30 at 10:07 -0400, Jeff Garzik wrote:
> > > John W. Linville wrote:
> > > > Lots of stuff here...probably best for 2.6.23...
> > > 
> > > Is this best for Linux users... or just easy for developers?
> > > 
> > > Won't putting off all these fixes until 2.6.23 leave the driver released 
> > > in 2.6.22 in shoddy shape?

> > If you think all the bits from this should just go to 2.6.22, that's
> > fine with me.  But I don't feel comfortable making that call given what
> > I thought were the constraints on pushing changes through during an rc
> > cycle.  When the merge window was open, we backported critical bug fixes
> > and necessary merge-requirement cleanups to the code in linville's tree,
> > but avoided changes that didn't impact function.
> 
> Any response on these points yet?  I've got yet more cleanups and a few
> other things queued in libertas-2.6 but I'd like to see where this
> discussion goes before sending a pull request for the new bits.

As for me, I have no great problem w/ the whole batch going to 2.6.22.
The driver is still new and most acknowledge it still has significant
defficiencies.  Most (but probably not all) of the patches would seem
to fit some definition of bug fix anyway.  I was just trying to err
on the side of caution and follow the normal "bugfixes in -rc" process.

Jeff, the branch in question is based off a vanilla 2.6.22-rc3.
So it is safe to pull (from a "won't mess-up my tree" perspective)
if you are so inclined.

John
-- 
John W. Linville
linville@tuxdriver.com
