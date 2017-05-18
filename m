From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC]RNDIS filter issue
Date: Thu, 18 May 2017 15:02:30 +0200
Message-ID: <87lgpuco7t.fsf@miraculix.mork.no>
References: <1495111085.6672.7.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:58257 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754011AbdERNDs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 09:03:48 -0400
In-Reply-To: <1495111085.6672.7.camel@suse.com> (Oliver Neukum's message of
        "Thu, 18 May 2017 14:38:05 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.com> writes:

> @@ -472,7 +489,6 @@ static void usbnet_cdc_zte_status(struct usbnet *dev,=
 struct urb *urb)
>=20=20
>  	if (urb->actual_length < sizeof(*event))
>  		return;
> -
>  	event =3D urb->transfer_buffer;
>=20=20
>  	if (event->bNotificationType !=3D USB_CDC_NOTIFY_NETWORK_CONNECTION) {


Spurious whitespace.

And building gives:

 /usr/local/src/git/linux/drivers/net/usb/cdc_ether.c:325:5: warning: symbo=
l 'usbnet_ether_cdc_bind' was not declared. Should it be static?

and maybe it should?  There is no use for it in any other module, yet.
Or you could declare it in usbnet.h, I guess.  Your choice.

Looks good to me if those two minor issues are fixed.  But do note that
I currently don't have any way to test this on real hardware...


Bj=C3=B8rn
