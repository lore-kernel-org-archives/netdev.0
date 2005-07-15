From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [stable] Re: [05/11] SMP fix for 6pack driver
Date: Fri, 15 Jul 2005 21:35:56 +0200
Message-ID: <20050715193556.GB18059@stusta.de>
References: <20050713184130.GA9330@kroah.com> <20050713184331.GG9330@kroah.com> <20050713220123.GA3292@electric-eye.fr.zoreil.com> <20050713221311.GA30039@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, Greg KH <gregkh@suse.de>,
	torvalds@osdl.org, akpm@osdl.org, Theodore Ts'o <tytso@mit.edu>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	netdev@vger.kernel.org, Justin Forbes <jmforbes@linuxtx.org>,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	"Randy.Dunlap" <rdunlap@xenotime.net>,
	Chuck Wolber <chuckw@quantumlinux.com>, jgarzik@pobox.com,
	stable@kernel.org, alan@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261797AbVGOTgC@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <20050713221311.GA30039@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 13, 2005 at 03:13:11PM -0700, Greg KH wrote:
> On Thu, Jul 14, 2005 at 12:01:23AM +0200, Francois Romieu wrote:
> > Greg KH <gregkh@suse.de> :
> > > -stable review patch.  If anyone has any objections, please let us know.
> > > 
> > > ------------------
> > > 
> > > 
> > > Drivers really only work well in SMP if they actually can be selected.
> > > This is a leftover from the time when the 6pack drive only used to be
> > > a bitrotten variant of the slip driver.
> > 
> > Is the guideline above from 28/04/2005 obsoleted ?
> > 
> >  - It must fix a problem that causes a build error (but not for things
> >    marked CONFIG_BROKEN), an oops, a hang, data corruption, a real
> >    security issue, or some "oh, that's not good" issue.  In short,
> >    something critical.
> 
> It lets the driver be built, when it previously could not be, unless the
> user used a config option that almost no one does...
> 
> That's pretty critical if you ask me.


I do agree with Francois regarding this issue:

AFAIR, there has been not one 2.6 kernel where this driver was available 
for SMP kernels. It's therefore untested which problems might arise with 
this driver on SMP systems. I'm not arguing against including this 
driver in 2.6.13, but 2.6.12.3 isn't the right place.


What surprises me most is that you accepted this patch is neither in 
2.6.13-rc3 nor in 2.6.13-rc3-mm1. There seems to be either an
(IMHO unfortunate) change in your policy of what patches to accept,
or there's a serious problem in your patch review process.


> thanks,
> 
> greg k-h

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
