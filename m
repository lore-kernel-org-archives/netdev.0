From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: ipw2100: firmware problem
Date: Thu, 9 Jun 2005 09:09:55 +0300
Message-ID: <200506090909.55889.vda@ilport.com.ua>
References: <002901c56c3b$8216cdd0$600cc60a@amer.sykes.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <abonilla@linuxwireless.org>, "'Pavel Machek'" <pavel@ucw.cz>,
        "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Netdev list'" <netdev@oss.sgi.com>,
        "'kernel list'" <linux-kernel@vger.kernel.org>,
        "'James P. Ketrenos'" <ipw2100-admin@linux.intel.com>
In-Reply-To: <002901c56c3b$8216cdd0$600cc60a@amer.sykes.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 08 June 2005 18:05, Alejandro Bonilla wrote:
> 
> > On Wednesday 08 June 2005 17:23, Pavel Machek wrote:
> > > Hi!
> > >
> > > I'm fighting with firmware problem: if ipw2100 is compiled into
> > > kernel, it is loaded while kernel boots and firmware loader
> > is not yet
> > > available. That leads to uninitialized (=> useless) adapter.
> 
> Pavel,
> 
> 	I might be lost here but... How is the firmware loaded when using the
> ipw2100-1.0.0/patches Kernel patch?
> 
> That patch normally works fine. It might not be the way you kernel
> developers would like it, but maybe that could work the same way?
> 
> 
> > >
> > > What's the prefered way to solve this one? Only load firmware when
> > > user does ifconfig eth1 up? [It is wifi, it looks like it would be
> > > better to start firmware sooner so that it can associate to the
> > > AP...].
> >
> > Do you want to associate to an AP when your kernel boots,
> > _before_ any iwconfig had a chance to configure anything?
> > That's strange.
> 
> Currently, when we install the driver, it associates to any open network on
> boot. This is good, cause we don't want to be typing the commands all the
> time just to associate. It works this way now and is pretty nice.

What is so nice about this? That Linux novice user with his new lappie
will join a neighbor's network every time he powers up the lappie,
even without knowing that?

That will be analogous to me plugging ethernet cable into the switch and
wanting it to work, without any IP addr config, even without DHCP client.
Just power up the box (or modprobe an eth module) and it works! Cool, eh?

For some reason, we do not do this for wired nets. Why should wireless
be different?
--
vda
