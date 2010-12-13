From: Greg KH <greg@kroah.com>
Subject: Re: brcm80211 hangs when disabling wireless
Date: Mon, 13 Dec 2010 11:42:03 -0800
Message-ID: <20101213194203.GB18431@kroah.com>
References: <1291930010.7960.30.camel@nimitz>
 <20101209214347.GA15172@suse.de>
 <1291931678.7960.32.camel@nimitz>
 <20101213193111.GK2576@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Hansen <dave@sr71.net>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	Jason Cooper <jason@lakedaemon.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg KH <gregkh@suse.de>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mike Rapoport <mike.rapoport@gmail.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Henry Ptasinski <henryp@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101213193111.GK2576@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 13, 2010 at 11:31:11AM -0800, Henry Ptasinski wrote:
> On Thu, Dec 09, 2010 at 01:54:38PM -0800, Dave Hansen wrote:
> > On Thu, 2010-12-09 at 13:43 -0800, Greg KH wrote:
> > > On Thu, Dec 09, 2010 at 01:26:50PM -0800, Dave Hansen wrote:
> > > > I've been getting hard hangs when I toggle the wireless on a Lenovo
> > > > S10-3.  It happens both with the physical switch and the Fn-F5 key
> > > > combo.  It's quite repeatable.  The system is quite stable when I'm not
> > > > trying to disable the wireless, though.
> > > 
> > > What kernel version is this?
> > > 
> > > Linus's latest tree has a known bug when the wireless is suspended and
> > > then resumed.  Broadcom is working on it but no patch is forthcoming
> > > yet.  Perhaps this is the same issue.
> > 
> > Yeah, it's 2.6.37-rc5 plus a pull from:
> > 
> > 	http://kernel.ubuntu.com/git?p=ikepanhc/ideapad-laptop.git;a=summary
> > 
> > That could easily be it.  Thanks, Greg.
> 
> Actually, I think it's the rfkill support (or lack thereof) that's causing you
> trouble.  But we're looking at that as well.
> 
> The outstanding reported issues that I'm aware of are:
> 	- 43224 crashes
> 	- missing rfkill support
> 	- suspend/resume problems
> 	- 4313 infinite loop in some cases
> 
> In terms of process, should these all get filed in bugzilla.kernel.org (or
> somewhere else), or just track them via email and our TODO list?

Where ever you feel comfortable putting them, some like email, some like
bugzilla.kernel.org.  The TODO list might be a bit tougher as it doesn't
always propagate to Linus fast enough (look at the differences between
it already in Linus's tree and linux-next, right?)

thanks,

greg k-h
