From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] rt2x00: Use ops name instead of device name
Date: Tue, 22 Feb 2011 14:47:25 -0500
Message-ID: <20110222194724.GG12153@tuxdriver.com>
References: <1298380368.6140.1193.camel@gandalf.stny.rr.com>
 <1298381695.2211.486.camel@localhost>
 <1298382263.6140.1196.camel@gandalf.stny.rr.com>
 <AANLkTinNUnq7JQDpTzCv24A7T7fMn9iPFisQEBZGkELr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Felix Fietkau <nbd@openwrt.org>,
	abogani@texware.it
To: Ivo Van Doorn <ivdoorn@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinNUnq7JQDpTzCv24A7T7fMn9iPFisQEBZGkELr@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 22, 2011 at 08:33:45PM +0100, Ivo Van Doorn wrote:
> Hi,
>=20
> On Tue, Feb 22, 2011 at 2:44 PM, Steven Rostedt <rostedt@goodmis.org>=
 wrote:
> > On Tue, 2011-02-22 at 13:34 +0000, Ben Hutchings wrote:
> >
> >> > 19: =A0 73474106 =A0 =A0 =A0 =A0 =A00 =A0 IO-APIC-fasteoi =A0 at=
a_piix, uhci_hcd:usb6, 0000:05:01.0
> >
> >> > =A0 =A0 rt2x00dev->irq =3D pci_dev->irq;
> >> > - =A0 rt2x00dev->name =3D pci_name(pci_dev);
> >> > + =A0 rt2x00dev->name =3D ops->name;
> >
> >
> >> But then how can users distinguish the IRQs for multiple devices h=
andled
> >> by the same driver? =A0(Probably unusual for WLAN devices, but sti=
ll
> >> possible.)
> >>
> >> I assume you can't use a net device name as there may be multiple =
net
> >> devices per bus device?
> >
> > Honestly, I do not know this code well enough, but this patch seeme=
d to
> > solve the problem at hand. Hence I sent it out to the experts hopin=
g
> > they either take this patch or come up with a proper solution ;)
> >
> > In any case, just posting the pci address is not a pretty answer.
>=20
> I just checked the other wireless drivers, and they all seem to use
> the modulename. So I guess your patch is correct. You can add my:
>=20
> Acked-by: Ivo van Doorn <IvDoorn@gmail.com>

I completely missed this series -- please be sure to Cc:
linux-wireless@vger.kernel.org if you resend, and/or resend the series
directly to me?

Thanks!

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
