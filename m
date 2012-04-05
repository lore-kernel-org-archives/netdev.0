From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: [3.4-rc1][Regression][network wireless] 'task xxxx blocked for more than 120 seconds' after resume
Date: Thu, 5 Apr 2012 22:08:21 +0200
Message-ID: <201204052208.21270.maciej.rutecki@gmail.com>
References: <201204022157.05598.maciej.rutecki@gmail.com> <201204052037.37497.maciej.rutecki@gmail.com> <1333652183.3494.21.camel@jlt3.sipsolutions.net>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333652183.3494.21.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On czwartek, 5 kwietnia 2012 o 20:56:23 Johannes Berg wrote:
> On Thu, 2012-04-05 at 20:37 +0200, Maciej Rutecki wrote:
> > On czwartek, 5 kwietnia 2012 o 12:32:54 Stanislaw Gruszka wrote:
> > > On Tue, Apr 03, 2012 at 10:07:49AM +0200, Johannes Berg wrote:
> > > > -ilw
> > > > +netdev
> > > > 
> > > > I have no idea what this could be, but I'm almost certain it's not
> > > > caused by our wireless driver. Looks more like rtl8169 is to blame.
> > > 
> > > I'm not sure. Looks like there is deadlock or infinite loop in process
> > > that holds rtnl lock. This can be wireless driver, wired driver or
> > > generic network code bug.
> > > 
> > > Maciej, please recompile with CONFIG_LOCKDEP and check if it will not
> > > find any deadlock. If not, when problem will happen please do
> > 
> > Did you mean "CONFIG_LOCKDEP_SUPPORT"?
> 
> No, _SUPPORT means you could enable CONFIG_LOCKDEP, but we would like to
> see this with CONFIG_LOCKDEP enabled.
> 
> johannes

Dmesg when CONFIG_LOCKDEP is set:

http://mrutecki.pl/download/kernel/3.4-rc1/netdev_resume/dmesg-lockdep.txt

Regards

-- 
Maciej Rutecki
http://www.mrutecki.pl
