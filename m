From: Dave Hansen <dave@sr71.net>
Subject: Re: brcm80211 hangs when disabling wireless
Date: Thu, 09 Dec 2010 13:54:38 -0800
Message-ID: <1291931678.7960.32.camel@nimitz>
References: <1291930010.7960.30.camel@nimitz>
	 <20101209214347.GA15172@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Brett Rudley <brudley@broadcom.com>,
	Henry Ptasinski <henryp@broadcom.com>,
	Nohee Ko <noheek@broadcom.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Mike Rapoport <mike.rapoport@gmail.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101209214347.GA15172@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-12-09 at 13:43 -0800, Greg KH wrote:
> On Thu, Dec 09, 2010 at 01:26:50PM -0800, Dave Hansen wrote:
> > I've been getting hard hangs when I toggle the wireless on a Lenovo
> > S10-3.  It happens both with the physical switch and the Fn-F5 key
> > combo.  It's quite repeatable.  The system is quite stable when I'm not
> > trying to disable the wireless, though.
> 
> What kernel version is this?
> 
> Linus's latest tree has a known bug when the wireless is suspended and
> then resumed.  Broadcom is working on it but no patch is forthcoming
> yet.  Perhaps this is the same issue.

Yeah, it's 2.6.37-rc5 plus a pull from:

	http://kernel.ubuntu.com/git?p=ikepanhc/ideapad-laptop.git;a=summary

That could easily be it.  Thanks, Greg.

-- Dave
