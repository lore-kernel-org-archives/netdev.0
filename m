From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: linux-wireless mailing list
Date: Wed, 10 Mar 2004 15:53:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040310235341.GA16621@bougret.hpl.hp.com>
References: <Pine.LNX.4.58.0403031656090.22365@marabou.research.att.com> <40469DA1.9090502@pobox.com> <20040305040352.GA16669@bougret.hpl.hp.com> <404F5461.80000@pobox.com> <20040310180602.GB9531@bougret.hpl.hp.com> <404F5DAC.4020807@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <404F5DAC.4020807@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 10, 2004 at 01:25:48PM -0500, Jeff Garzik wrote:
> 
> A type-specific wireless_ops is something that I definitely want to see.
> 
> It reduces code in the drivers, by increasing the amount of code that 
> can be made generic.  It's much better to, for example, have all the 
> user data (length, etc.) validate checks, and capable(CAP_xxx) security 
> checks all in one place.  And perhaps more importantly, a type-specific 
> wireless_ops makes it harder for driver writers to screw up ;-)  That's 
> an important attribute in a driver API, I've come to learn...

	You could define a set of wrapper that would convert from
iw_handler to a type specific call. This is already what is done in
the case of iwspy support ; the driver just adds in the iw_handler
table the generic spy handlers provided in wireless.c. You can check
in airo.c around line 6823.
	But honestly, I believe that there are other more urgent
things to do (such as WPA support for example).

> 	Jeff

	Jean
