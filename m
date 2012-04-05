From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [3.4-rc1][Regression][network wireless] 'task xxxx blocked for
 more than 120 seconds' after resume
Date: Thu, 05 Apr 2012 20:56:23 +0200
Message-ID: <1333652183.3494.21.camel@jlt3.sipsolutions.net>
References: <201204022157.05598.maciej.rutecki@gmail.com>
	 <1333440469.3574.0.camel@jlt3.sipsolutions.net>
	 <20120405103254.GE2378@redhat.com>
	 <201204052037.37497.maciej.rutecki@gmail.com>
	 (sfid-20120405_203812_209408_5261E33E)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201204052037.37497.maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (sfid-20120405_203812_209408_5261E33E)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-04-05 at 20:37 +0200, Maciej Rutecki wrote:
> On czwartek, 5 kwietnia 2012 o 12:32:54 Stanislaw Gruszka wrote:
> > On Tue, Apr 03, 2012 at 10:07:49AM +0200, Johannes Berg wrote:
> > > -ilw
> > > +netdev
> > > 
> > > I have no idea what this could be, but I'm almost certain it's not
> > > caused by our wireless driver. Looks more like rtl8169 is to blame.
> > 
> > I'm not sure. Looks like there is deadlock or infinite loop in process
> > that holds rtnl lock. This can be wireless driver, wired driver or
> > generic network code bug.
> > 
> > Maciej, please recompile with CONFIG_LOCKDEP and check if it will not
> > find any deadlock. If not, when problem will happen please do
> 
> Did you mean "CONFIG_LOCKDEP_SUPPORT"?

No, _SUPPORT means you could enable CONFIG_LOCKDEP, but we would like to
see this with CONFIG_LOCKDEP enabled.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
