From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [RFC][PATCH] Very basic sysfs support for ATM devices (updated)
Date: Sat, 05 Feb 2005 20:33:18 -0500
Message-ID: <200502060133.j161XIj3007281@ginger.cmf.nrl.navy.mil>
References: <20050204201327.GA2439@katya>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com, linux-atm-general@lists.sourceforge.net,
        usbatm@lists.infradead.org
To: Roman Kagan <rkagan@mail.ru>
Reply-To: chas3@users.sourceforge.net
In-reply-to: Your message of "Fri, 04 Feb 2005 23:13:27 +0300."
             <20050204201327.GA2439@katya>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20050204201327.GA2439@katya>,Roman Kagan writes:
>> +static CLASS_DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
>Maybe it should better be "esi", to match the name in struct atm_dev?

its called address for ethernet network interfaces so i guess calling
it address here is sensible.

>script, and hoping that was enough for the driver to complete
>initializing atm_dev.  I suspect the only way to fix it is to split the
>atm_dev initialization into two stages, allocation and registration, as
>it is done for net_device.

yeah which is why i just wanted to convert atm_dev to just be a netdevice.
the code is already written and "stable".
