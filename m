From: Pavel Machek <pavel@ucw.cz>
Subject: Re: ipw2100: firmware problem
Date: Thu, 9 Jun 2005 23:11:13 +0200
Message-ID: <20050609211113.GC4173@elf.ucw.cz>
References: <200506090909.55889.vda@ilport.com.ua> <20050608.231657.59660080.davem@davemloft.net> <20050609104205.GD3169@elf.ucw.cz> <20050609.125324.88476545.davem@davemloft.net> <42A8AE2A.4080104@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, vda@ilport.com.ua,
        abonilla@linuxwireless.org, jgarzik@pobox.com, netdev@oss.sgi.com,
        ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <42A8AE2A.4080104@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

> >I agree.
> >
> >There is a similar problem in the Acenic driver, it brings the
> >link up and receives broadcast packets as soon as the driver
> >is loaded.  Mostly this is because the driver inits the chip
> >and registers the IRQ handler at probe time, whereas nearly
> >every other driver does this at ->open() time.
> >  
> >
> The ipw2100 originally postponed doing any initialization until open was
> called.  The problem at that time was that distributions were crafted to
> rely on link detection (I believe via ethtoolop's get_link) before they
> would bring the interface up.
> 
> With a wireless device, you don't have link until you are associated... 
> chicken and egg.  The solution was to move initialization and
> association to the probe.
> 
> I don't know if all the distributions have moved away from this model. 
> If they have and the devices are brought up regardless of link, then
> going back to delaying radio initialization until the open() is called
> is workable. 

Ook, great, I see.
								Pavel
