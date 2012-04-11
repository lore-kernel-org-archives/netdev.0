From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: [3.4-rc1][Regression][network wireless] 'task xxxx blocked for more than 120 seconds' after resume
Date: Wed, 11 Apr 2012 21:37:47 +0200
Message-ID: <201204112137.47854.maciej.rutecki@gmail.com>
References: <201204022157.05598.maciej.rutecki@gmail.com> <1333657409.3494.22.camel@jlt3.sipsolutions.net> <20120405210122.GA12135@electric-eye.fr.zoreil.com>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120405210122.GA12135@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On czwartek, 5 kwietnia 2012 o 23:01:22 Francois Romieu wrote:
> Johannes Berg <johannes@sipsolutions.net> :
> > On Thu, 2012-04-05 at 22:08 +0200, Maciej Rutecki wrote:
> > > Dmesg when CONFIG_LOCKDEP is set:
> > > 
> > > http://mrutecki.pl/download/kernel/3.4-rc1/netdev_resume/dmesg-lockdep.
> > > txt
> > 
> > Looks like rtl8169's fault:
> Fix is on the way to mainline, see http://patchwork.ozlabs.org/patch/150541
Seems be resolved in -rc2. Only in dmesg still I have messages "netlink: 140 
bytes leftover after parsing attributes.". It seems be another issue.

Thanks
-- 
Maciej Rutecki
http://www.mrutecki.pl
