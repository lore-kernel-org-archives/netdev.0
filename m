From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] atm: correct sysfs 'device' link creation and parent
 relationships
Date: Wed, 08 Dec 2010 12:15:32 -0800 (PST)
Message-ID: <20101208.121532.232745367.davem@davemloft.net>
References: <1291587480.17538.12.camel@dcbw.foobar.com>
	<AANLkTikhkVPcibAH8cSRvZSLop=Ew19Tn=KtY7prkKUn@mail.gmail.com>
	<20101208.101121.71114237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, duncan.sands-GANU6spQydw@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chas-vT06rRrALxcmhCb6mdbn6A@public.gmane.org
To: kay.sievers-tD+1rO4QERM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101208.101121.71114237.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Wed, 08 Dec 2010 10:11:21 -0800 (PST)

> From: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
> Date: Tue, 7 Dec 2010 08:35:53 +0100
>=20
>> On Sun, Dec 5, 2010 at 23:17, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>>> The ATM subsystem was incorrectly creating the 'device' link for AT=
M
>>> nodes in sysfs. =A0This led to incorrect device/parent relationship=
s
>>> exposed by sysfs and udev. =A0Instead of rolling the 'device' link =
by hand
>>> in the generic ATM code, pass each ATM driver's bus device down to =
the
>>> sysfs code and let sysfs do this stuff correctly.
>>=20
>> Looks good to me.
>=20
> I've applied this to net-2.6, thanks Dan.

Actually I'm reverting, it breaks the build.

Did you even grep for "atm_dev_register()" after changning the number
of arguments, or were you depending upon build failures to guide you?

Please never do the latter, as it always leads to things like this.

drivers/atm/fore200e.c:2577:7: error: too few arguments to function 'at=
m_dev_register'
drivers/atm/iphase.c:3175:2: error: too few arguments to function 'atm_=
dev_register'
=2E..
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
