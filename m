From: jamal <hadi@cyberus.ca>
Subject: Re: creating a netdevice
Date: 02 Mar 2005 16:41:17 -0500
Message-ID: <1109799677.1098.198.camel@jzny.localdomain>
References: <20050302133828.45232.qmail@web26610.mail.ukl.yahoo.com>
	 <20050302112622.33be433c@dxpl.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: BZ Benny <bennybbz@yahoo.fr>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050302112622.33be433c@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Can you explain why you need to create a net device? Linux (and many
other OSes) typically tie discovery of hardware resources to creating a
network device i.e the kernel creates it for you (this is true even when
the discovery is done post bootup). The only exception is things like 
tun/ethertap as Stephen mentions. Things like allocation of ifindices 
are also under the control of the OS - even when you are able to create.

cheers,
jamal


On Wed, 2005-03-02 at 14:26, Stephen Hemminger wrote:
> On Wed, 2 Mar 2005 14:38:28 +0100 (CET)
> BZ Benny <bennybbz@yahoo.fr> wrote:
> 
> > Hi
> > 
> > I want to create a network interface from the user
> > space,
> > is it possible?
> 
> No, you can't create a network interface from user space.
> You probably want to use tun/tap or ethertap device.
> 
> 
