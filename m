From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usb: add device IDs for Dell 5804 (Novatel E371) WWAN
 card
Date: Wed, 01 May 2013 14:42:41 -0400 (EDT)
Message-ID: <20130501.144241.1818296448373016452.davem@davemloft.net>
References: <1367431305.12353.8.camel@dcbw.foobar.com>
	<87r4hqbleh.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcbw@redhat.com, linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org, stable@vger.kernel.org,
	smurf@smurf.noris.de, dagofthedofg@gmail.com
To: bjorn@mork.no
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87r4hqbleh.fsf@nemi.mork.no>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Wed, 01 May 2013 20:33:10 +0200

> Dan Williams <dcbw@redhat.com> writes:
>=20
>> A rebranded Novatel E371 for AT&T's LTE bands.
>=20
> I don't think we're handling the Novatel branded E371 yet?  I tried
> googling for ID of that, but were unable to find it.  I guess you don=
't
> know either...  Well, nothing we can do about that until someone repo=
rts
> it.
>=20
> For the qmi_wwan part:
> Acked-by: Bj=F8rn Mork <bjorn@mork.no>
>=20
>=20
>> diff --git a/drivers/usb/serial/option.c b/drivers/usb/serial/option=
=2Ec
>> index 558adfc..569caf6 100644
>> --- a/drivers/usb/serial/option.c
>> +++ b/drivers/usb/serial/option.c
>=20
> Combining net and usb patches in the same commit is probably not wise=
?

Yes, this causes problems, please re-submit the networking portion all
by itself.
