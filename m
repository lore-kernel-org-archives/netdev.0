From: "Henry Ptasinski" <henryp@broadcom.com>
Subject: Re: brcm80211 hangs when disabling wireless
Date: Mon, 13 Dec 2010 11:31:11 -0800
Message-ID: <20101213193111.GK2576@broadcom.com>
References: <1291930010.7960.30.camel@nimitz>
 <20101209214347.GA15172@suse.de> <1291931678.7960.32.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Greg KH" <gregkh@suse.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	"Brett Rudley" <brudley@broadcom.com>,
	"Jason Cooper" <jason@lakedaemon.net>,
	"Mike Rapoport" <mike.rapoport@gmail.com>,
	"Andy Shevchenko" <andy.shevchenko@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Henry Ptasinski" <henryp@broadcom.com>, arend@broadcom.com,
	rvossen@broadcom.com
To: "Dave Hansen" <dave@sr71.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291931678.7960.32.camel@nimitz>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 09, 2010 at 01:54:38PM -0800, Dave Hansen wrote:
> On Thu, 2010-12-09 at 13:43 -0800, Greg KH wrote:
> > On Thu, Dec 09, 2010 at 01:26:50PM -0800, Dave Hansen wrote:
> > > I've been getting hard hangs when I toggle the wireless on a Lenovo
> > > S10-3.  It happens both with the physical switch and the Fn-F5 key
> > > combo.  It's quite repeatable.  The system is quite stable when I'm not
> > > trying to disable the wireless, though.
> > 
> > What kernel version is this?
> > 
> > Linus's latest tree has a known bug when the wireless is suspended and
> > then resumed.  Broadcom is working on it but no patch is forthcoming
> > yet.  Perhaps this is the same issue.
> 
> Yeah, it's 2.6.37-rc5 plus a pull from:
> 
> 	http://kernel.ubuntu.com/git?p=ikepanhc/ideapad-laptop.git;a=summary
> 
> That could easily be it.  Thanks, Greg.

Actually, I think it's the rfkill support (or lack thereof) that's causing you
trouble.  But we're looking at that as well.

The outstanding reported issues that I'm aware of are:
	- 43224 crashes
	- missing rfkill support
	- suspend/resume problems
	- 4313 infinite loop in some cases

In terms of process, should these all get filed in bugzilla.kernel.org (or
somewhere else), or just track them via email and our TODO list?

Thanks,
- Henry
