From: Roman Kagan <rkagan@mail.ru>
Subject: Re: [Linux-ATM-General] [RFC][PATCH] Very basic sysfs support for ATM devices (updated)
Date: Sun, 6 Feb 2005 22:19:18 +0300
Message-ID: <20050206191918.GA2369@katya>
References: <20050204201327.GA2439@katya> <200502060133.j161XIj3007281@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-atm-general@lists.sourceforge.net,
        usbatm@lists.infradead.org
To: chas3@users.sourceforge.net
Content-Disposition: inline
In-Reply-To: <200502060133.j161XIj3007281@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 05, 2005 at 08:33:18PM -0500, chas williams - CONTRACTOR wrote:
> In message <20050204201327.GA2439@katya>,Roman Kagan writes:
> >initializing atm_dev.  I suspect the only way to fix it is to split the
> >atm_dev initialization into two stages, allocation and registration, as
> >it is done for net_device.
> 
> yeah which is why i just wanted to convert atm_dev to just be a netdevice.
> the code is already written and "stable".

Is it publically available?  Linux-ATM CVS appears to contain no
kernelspace code.  I'm just curious how atm_dev attributes are mapped to
net_device's, which doesn't look easy with the current atm_dev and
net_device.

Also, is it scheduled for inclusion in the mainline any time soon?  If
it is, maybe we shouldn't create an atm-specific user-visible interface
in sysfs and hotplug which is going to be obsoleted by the net generic
one in the near future?

Roman.
