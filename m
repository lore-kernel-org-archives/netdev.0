From: Greg KH <greg@kroah.com>
Subject: Re: [usb regression] Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Tue, 1 Jan 2008 22:00:06 -0800
Message-ID: <20080102060006.GA27693@kroah.com>
References: <20071231052500.GB4187@kroah.com> <Pine.LNX.4.44L0.0712311237150.7182-100000@iolanthe.rowland.org> <20071231192643.GA25341@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Mohr <andi@lisas.de>, Ingo Molnar <mingo@elte.hu>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Denis V. Lunev" <den@openvz.org>,
	USB list <linux-usb@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:49502 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485AbYABF7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 00:59:00 -0500
Content-Disposition: inline
In-Reply-To: <20071231192643.GA25341@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2007 at 11:26:43AM -0800, Greg KH wrote:
> On Mon, Dec 31, 2007 at 12:49:52PM -0500, Alan Stern wrote:
> > On Sun, 30 Dec 2007, Greg KH wrote:
> > 
> > > > It looks like Greg misused the debugfs API -- which is ironic, because
> > > > he wrote debugfs in the first place!  :-)
> > > 
> > > Oh crap, sorry, I did mess that up :(

Ok, no, I didn't write that patch, I'm getting very confused here.

In 2.6.24-rc6 there is no usage of debugfs in the ohci driver.

In the -mm tree there is a patch, from Tony Jones, that moves some debug
code out of sysfs and into debugfs where it belongs.  It does it for
both the ehci and ohci USB host controller drivers, and this is the code
that is incorrect if CONFIG_DEBUGFS is not enabled.

So, for the 2.6.24 release, nothing needs to be changed, all is good,
and there is no regression.

Right?  Or am I still confused about this whole thing?

I will go fix up Tony's patches in the -mm tree that do not handle the
error return values from debugfs properly, but that is not such a rush,
as Tony is on vacation for a few weeks, and those patches are going to
be going in only after 2.6.24 is out.

Hm, I wonder if this means I can go back to drinking more holiday
wine... :)

thanks,

greg k-h
