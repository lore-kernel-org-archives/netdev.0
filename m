From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm: mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Fri, 3 Jun 2011 12:01:21 +0200
Message-ID: <201106031201.21933.oneukum@suse.de>
References: <1306922913-17803-1-git-send-email-metze@samba.org> <5203.1307062683@turing-police.cc.vt.edu> <2AC7D4AD8BA1C640B4C60C61C8E520153E3C13B5F2@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>,
	Dan Williams <dcbw@redhat.com>,
	Stefan Metzmacher <metze@samba.org>,
	Oliver Neukum <oliver@neukum.name>,
	"Greg Kroah-Hartman" <gregkh@suse.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C13B5F2@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 3. Juni 2011, 11:45:38 schrieb Alexey ORISHKO:
> > -----Original Message-----
> > From: Valdis.Kletnieks@vt.edu [mailto:Valdis.Kletnieks@vt.edu]
> > Sent: Friday, June 03, 2011 2:58 AM
> >=20
> > > A follow-on to this is that if you really care about specific
> > devices,
> > > your application can use udev rules to "tag" specific interfaces
> > based
> > > on USB VID/PID/GUID or other device attributes, and check for tho=
se
> > > tags in your program.  Use udev (good) or netlink (good) or
> > > SIOCGIFCONF (bad) to enumerate the various network interfaces on =
the
> > > system and pick the
> >=20
> > I think Alexey's point was that the patch will hose up programs tha=
t
> > currently do the netlink or  SIOCGIFCONF thing and look for
> > FLAG_POINTTOPOINT.
>=20
> Just to clarify, I was objecting to renaming interface name mostly be=
cause
> devices which use CDC NCM function might be something different from =
wwan
> devices. I would prefer to keep a generic name of interface (usbX or =
ethX).
>=20
> As an option anyone can use udev rules to set interface name they wan=
t=20
> for their device based on VID/PID or MAC address or something else.
> I've already provided udev rule example earlier in this thread.

This is not ideal. Distributions cannot care about every VIP:PID value.
If a device with an NCM interface needs to be treated in a special
manner we'd better have a special name for such interfaces.

	Regards
		Oliver
--=20
- - -=20
SUSE LINUX Products GmbH, GF: Jeff Hawn, Jennifer Guild, Felix Imend=F6=
rffer, HRB 16746 (AG N=FCrnberg)=20
Maxfeldstra=DFe 5                        =20
90409 N=FCrnberg=20
Germany=20
- - -=20
