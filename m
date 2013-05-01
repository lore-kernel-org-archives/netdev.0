From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] usb: add device IDs for Dell 5804 (Novatel E371) WWAN
 card
Date: Wed, 01 May 2013 15:03:40 -0500
Message-ID: <1367438620.12353.11.camel@dcbw.foobar.com>
References: <1367431305.12353.8.camel@dcbw.foobar.com>
	 <87r4hqbleh.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>, stable@vger.kernel.org,
	Matthias Urlichs <smurf@smurf.noris.de>, dagofthedofg@gmail.com
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755916Ab3EAUBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 16:01:34 -0400
In-Reply-To: <87r4hqbleh.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-01 at 20:33 +0200, Bj=C3=B8rn Mork wrote:
> Dan Williams <dcbw@redhat.com> writes:
>=20
> > A rebranded Novatel E371 for AT&T's LTE bands.
>=20
> I don't think we're handling the Novatel branded E371 yet?  I tried
> googling for ID of that, but were unable to find it.  I guess you don=
't
> know either...  Well, nothing we can do about that until someone repo=
rts
> it.

See the referenced bug report which prompted this:

https://bugzilla.redhat.com/show_bug.cgi?id=3D955426

It's definitely QMI capable.

Dan

> For the qmi_wwan part:
> Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>=20
>=20
> > diff --git a/drivers/usb/serial/option.c b/drivers/usb/serial/optio=
n.c
> > index 558adfc..569caf6 100644
> > --- a/drivers/usb/serial/option.c
> > +++ b/drivers/usb/serial/option.c
>=20
> Combining net and usb patches in the same commit is probably not wise=
?
>=20
>=20
>=20
> Bj=C3=B8rn
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
