From: Pavel Machek <pavel@ucw.cz>
Subject: Re: ipw2100: firmware problem
Date: Thu, 9 Jun 2005 00:34:37 +0200
Message-ID: <20050608223437.GB2614@elf.ucw.cz>
References: <20050608142310.GA2339@elf.ucw.cz> <42A723D3.3060001@linux.intel.com> <20050608212707.GA2535@elf.ucw.cz> <42A76719.2060700@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev list <netdev@oss.sgi.com>,
        kernel list <linux-kernel@vger.kernel.org>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <42A76719.2060700@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

> >Having a parameter to control this seems a bit too complex to me.
> >
> >How is 
> >
> >insmod ipw2100 enable=1
> >
> >different from
> >
> >insmod ipw2100
> >iwconfig eth1 start_scanning_or_whatever
> >
> >?
> It defaults to enabled, so you just need to do:
> 
>     insmod ipw2100
> 
> and it will auto associate with an open network.  For the use case where
> users want the device to load but not initialize, they can use
> 
>     insmod ipw2100 disable=1
> 
> If hotplug and firmware loading worked early in the init sequence, no
> one would have issue with the current model; it works as users expect it
> to work.  It magically finds and associates to networks, and your
> network scripts can then kick off DHCP, all with little to no special
> crafting or utility interfacing. 

Actually it would still transmit when user did not want it to. I
believe that staying "quiet" is right thing, long-term. And it could
solve firmware-loading problems, short-term...

How long does association with AP take? Anyway it should be easy to
tell driver to associate ASAP, just after the insmod...
								Pavel
