From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH] r8169: Add values missing in @get_stats64 from HW
 counters
Date: Thu, 20 Aug 2015 11:41:36 +0200
Message-ID: <20150820094136.GA16132@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <20150818214017.GA14914@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2F4B846@RTITMBSV03.realtek.com.tw>
 <20150819091318.GV17917@calimero.vinschen.de>
 <0835B3720019904CB8F7AA43166CEEB2F4BF49@RTITMBSV03.realtek.com.tw>
 <20150819130744.GA24832@calimero.vinschen.de>
 <20150819142416.GA26271@calimero.vinschen.de>
 <20150819192414.GC30904@calimero.vinschen.de>
 <0835B3720019904CB8F7AA43166CEEB2F4C1FA@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="oyUTqETQ0mS9luUI"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	nic_swsd <nic_swsd@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:48698 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbbHTJlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 05:41:39 -0400
Content-Disposition: inline
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F4C1FA@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 20 02:43, Hayes Wang wrote:
> Corinna Vinschen [mailto:vinschen@redhat.com]
> > Sent: Thursday, August 20, 2015 3:24 AM
> [...]
> > +	/*
> > +	 * Versions prior to RTL_GIGA_MAC_VER_19 don't support resetting the
> > +	 * tally counters.
> > +	 */
> > +	if (tp->mac_version >=3D RTL_GIGA_MAC_VER_19) {
> > +		RTL_W32(CounterAddrHigh, 0);
> > +		RTL_W32(CounterAddrLow, CounterReset);
>=20
> I check these with our engineers, and they say the bit 6 ~ 63 should be t=
he
> valid 64 byte alignment memory address. Although you don=E2=80=99t want t=
o dump
> the counters, the hw may also clear the data in the memory which is indic=
ated
> by bit 6 ~ 63, when you reset the counters.

Ok, that's easy enough to implement.  What about CmdRxEnb?  Are there
chips which need this flag set to perform the counter reset?


Thanks,
Corinna

--oyUTqETQ0mS9luUI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV1aDQAAoJEPU2Bp2uRE+gnb0P/0JK4UbWD7C4ksseWWn5lBAy
iLJeRziS/veGhLc4dzhNhgs7WFaciAeKh+ezuFXIEMq94SdtzhHvhqBYc1ayoPn4
EyXDim7h7+Je19wmmrvOYjL+Ku/sKDIqS6AhYsDRZQoOEyVEvKDqdPBcDwqtvDty
AyWrnotKIMDjXavGwbeUR+ipDLKKQx9cubNzde3q9r0w1V+DjUR1+JftoSbWur4t
uahxnqXo3vFvRov8YsT2jt5nctzIihgE4fB8XpLDLJSiSGwOPPUEGeXJpbo73ug5
EIpWOUAcQItyaNsnoq55SreYjGucFx/V3w0vxiXnaT/PH/IZ05mjo0+PhdNTT97D
RZUq5zG8eLF2RCzbl2397oKHf4kYNaCVRsRZxxV9vo0QuDx7cZ3BYt7fJQWVrn+O
zDaOEXslyB1vNBdx4q556H2ajh68F3qUdFQ89zyQNsCufPu7pwLN/GOejsvvQNiU
TC8+vtsr75VagXQ7Ud5FBKmKgkoa1UmtHmYqAkfisYTRyXfsoqZmxlDhwFfb9S/j
YVVANkTputJpJ4pXyrJ8K9lQsEiB3r3aVjpRgr2//kdtaZZa544gJAZKcKG8iQf6
v3N9IbNRZ+kFudqmQxfTu2BljGEbOnfz7VLDeCaa8ljoW2x32VSfRoG5H0xA/hUI
SqDW3IIZbssocpnfOVpQ
=vtys
-----END PGP SIGNATURE-----

--oyUTqETQ0mS9luUI--
