From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 2/2] usbnet: Convert dbg to dev_dbg and neatening
Date: Wed, 4 May 2011 14:42:16 +0200
Message-ID: <BANLkTikW8W8ZVSYMyOSJxiWouLE1_tEiDQ@mail.gmail.com>
References: <cover.1304445019.git.joe@perches.com> <f86364fbdc335fadad003081d010843579e95765.1304445019.git.joe@perches.com>
 <4DC13A1B.8020004@ru.mvista.com> <1304511102.1788.91.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sshtylyov@mvista.com>,
	Oliver Neukum <oneukum@suse.de>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:42315 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961Ab1EDMmg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 08:42:36 -0400
In-Reply-To: <1304511102.1788.91.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/4 Joe Perches <joe@perches.com>:
> On Wed, 2011-05-04 at 15:35 +0400, Sergei Shtylyov wrote:
>> Hello.
>
> And hello to you Sergei.
>
> On 03-05-2011 22:17, Joe Perches wrote:
>> > Use the more standard logging form.
>> > Add a bit more tidying style.
>> =C2=A0 =C2=A0 Style changes look rather doubtful to me...
>> > =C2=A0 drivers/net/usb/usbnet.c | =C2=A0 23 +++++++++++-----------=
-
>> > diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> []
>> > @@ -192,8 +192,8 @@ static int init_status(struct usbnet *dev, str=
uct usb_interface *intf)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> >
>> > =C2=A0 =C2=A0 pipe =3D usb_rcvintpipe(dev->udev,
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 dev->status->desc.bEndpointAddress
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &=
 USB_ENDPOINT_NUMBER_MASK);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 (dev->status->desc.bEndpointAddress
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &=
 USB_ENDPOINT_NUMBER_MASK));
>>
>> =C2=A0 =C2=A0 Why add parens?
>
> Leading & uses are almost always addressof.
> This makes it easier for me to see that it's not an addressof use.

This is a clear case where 80-char limit impairs code readability. Why
not just use another variable?

int epn =3D dev->status->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MA=
SK;
pipe =3D usb_rcvintpipe(dev->udev, epn);

Best Regards,
Micha=C5=82 Miros=C5=82aw
