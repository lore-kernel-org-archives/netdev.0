From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [RFC][PATCH] Very basic sysfs support for ATM devices (updated)
Date: Tue, 08 Feb 2005 10:02:19 -0500
Message-ID: <200502081502.j18F2ITI010672@ginger.cmf.nrl.navy.mil>
References: <rkagan@mail.ru>
To: Roman Kagan <rkagan@mail.ru>, netdev@oss.sgi.com,
        linux-atm-general@lists.sourceforge.net, usbatm@lists.infradead.org
In-Reply-To: Message from Roman Kagan <rkagan@mail.ru>
   of "Sun, 06 Feb 2005 22:19:18 +0300." <20050206191918.GA2369@katya>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20050206191918.GA2369@katya>,Roman Kagan writes:
>Is it publically available?  Linux-ATM CVS appears to contain no
>kernelspace code.  I'm just curious how atm_dev attributes are mapped to
>net_device's, which doesn't look easy with the current atm_dev and
>net_device.

not really.  i just stuck attached the atm_dev to the netdevice's priv.
the only thing that really bothered me about this was that the atm
devices would show in an ifconfig.  this might confuse some people.

>it is, maybe we shouldn't create an atm-specific user-visible interface
>in sysfs and hotplug which is going to be obsoleted by the net generic
>one in the near future?

with sysfs support the only thing left to 'fix' would be splitting of
allocation/registration.
