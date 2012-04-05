From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [3.4-rc1][Regression][network wireless] 'task xxxx blocked for more than 120 seconds' after resume
Date: Thu, 5 Apr 2012 23:01:22 +0200
Message-ID: <20120405210122.GA12135@electric-eye.fr.zoreil.com>
References: <201204022157.05598.maciej.rutecki@gmail.com> <201204052037.37497.maciej.rutecki@gmail.com> <1333652183.3494.21.camel@jlt3.sipsolutions.net> <201204052208.21270.maciej.rutecki@gmail.com> <1333657409.3494.22.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: maciej.rutecki@gmail.com, Stanislaw Gruszka <sgruszka@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1333657409.3494.22.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes@sipsolutions.net> :
> On Thu, 2012-04-05 at 22:08 +0200, Maciej Rutecki wrote:
> 
> > Dmesg when CONFIG_LOCKDEP is set:
> > 
> > http://mrutecki.pl/download/kernel/3.4-rc1/netdev_resume/dmesg-lockdep.txt
> 
> Looks like rtl8169's fault:

Fix is on the way to mainline, see http://patchwork.ozlabs.org/patch/150541

-- 
Ueimor

Will code drivers for food.
