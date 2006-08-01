From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Tue, 1 Aug 2006 08:21:49 -0400
Message-ID: <20060801122142.GB29208@tuxdriver.com>
References: <200607270037.22384.flamingice@sourmilk.net> <20060731203113.GG10138@tuxdriver.com> <200607311351.35757.flamingice@sourmilk.net> <20060801095650.GA6831@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:22793 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751274AbWHAMWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 08:22:17 -0400
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20060801095650.GA6831@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 10:56:50AM +0100, Christoph Hellwig wrote:
> On Mon, Jul 31, 2006 at 01:51:31PM -0700, Michael Wu wrote:
> > On Monday 31 July 2006 13:31, John W. Linville wrote:
> > > As usual I'll depend on Jiri to merge d80211 stack patches, then
> > > send me a pull request.  If I apply your "Switch drivers to d80211"
> > > series now, that will undoutedly cause a breakage when Jiri asks me
> > > to pull this later.
> > >
> > Yeah, there needs to be a new (and smaller) set of patches to switch drivers 
> > to the d80211.h header.
> 
> NACK again.  Driver should continue to use the ieee80211.h header forever.

I don't anticipate the d80211 naming conventions to ever make it out
of wireless-dev.  By the time we are ready to push that stuff upstream,
we will have cleaned-up our messes.

This does raise the question: Should we start taking patches to
wireless-dev that migrate the current (i.e. ieee80211/softmac) stack
out of the kernel?  This would include (re-)moving the current stack
code, pointing non-migrated drivers (ipw2[12]00, zd1211rw) at the old
code, moving drivers out of drivers/net/wireless/d80211 up a level,
removing the softmac-based version of the bcm43xx driver, etc.

Are we ready for this?  Who wants to be the wireless janitor?

Whether Michael's patches come before or after this clean-up
really doesn't matter.  I'd probably rather have them now.  It only
complicates the migration slightly, while accomplishing something
useful.

John
-- 
John W. Linville
linville@tuxdriver.com
