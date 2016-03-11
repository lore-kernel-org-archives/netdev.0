From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Fri, 11 Mar 2016 21:04:11 +0100
Message-ID: <56E324BB.1050709@imap.cc>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
 <1457108303.2651.112.camel@tiscali.nl> <56DADA57.9010200@imap.cc>
 <1457340486.2737.19.camel@tiscali.nl> <56E09F4A.8010202@imap.cc>
 <56E15211.7080206@linux-pingi.de> <1457614704.2478.11.camel@tiscali.nl>
 <56E1A39F.1010005@linux-pingi.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6338061622896799458=="
Cc: devel@driverdev.osuosl.org, Arnd Bergmann <arnd@arndb.de>,
 linux-doc@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: isdn@linux-pingi.de, Paul Bolle <pebolle@tiscali.nl>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <56E1A39F.1010005@linux-pingi.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============6338061622896799458==
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="kuQc2vVRG6DCDvTHoiMgLhPGJQc0B6gCC"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kuQc2vVRG6DCDvTHoiMgLhPGJQc0B6gCC
Content-Type: multipart/mixed; boundary="HdLOThLwLPig1KegWK94f2f4iGiJkdOoe"
From: Tilman Schmidt <tilman@imap.cc>
To: isdn@linux-pingi.de, Paul Bolle <pebolle@tiscali.nl>
Cc: Arnd Bergmann <arnd@arndb.de>,
 Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
 linux-arm-kernel@lists.infradead.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org,
 linux-doc@vger.kernel.org, netdev@vger.kernel.org,
 Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>
Message-ID: <56E324BB.1050709@imap.cc>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
 <1457108303.2651.112.camel@tiscali.nl> <56DADA57.9010200@imap.cc>
 <1457340486.2737.19.camel@tiscali.nl> <56E09F4A.8010202@imap.cc>
 <56E15211.7080206@linux-pingi.de> <1457614704.2478.11.camel@tiscali.nl>
 <56E1A39F.1010005@linux-pingi.de>
In-Reply-To: <56E1A39F.1010005@linux-pingi.de>

--HdLOThLwLPig1KegWK94f2f4iGiJkdOoe
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 10.03.2016 um 17:41 schrieb isdn@linux-pingi.de:
> Am 10.03.2016 um 13:58 schrieb Paul Bolle:
>> On do, 2016-03-10 at 11:53 +0100, isdn@linux-pingi.de wrote:
>>> mISDN with CAPI support works just fine with pppd and pppdcapiplugin
>>> and the CAPI works for all mISDN HW.
>>
>> In the mainline tree the mISDN and CAPI stacks are effectively separat=
e.

Correct.

> Since 2012 mISDN has a cAPI20 interface, pure in userspace.

To expand: The documented interface for CAPI 2.0 applications is the
shared library libcapi20.so. Originally that library just interfaced to
the kernel CAPI subsystem through /dev/capi20. Later it was extended to
support different access paths to ISDN devices:
- via /dev/capi20 and kernel CAPI as before
- over the network and a remote CAPI server running rcapid
- over the network to FRITZ!Box router via AVM's CAPI-over-TCP service
- last but not least, via the mISDNcapid daemon and mISDN

Of course this cuts off anything that doesn't pass through libcapi20.so,
including applications that (against the standard) access /dev/capi20
directly but also the capidrv.ko i4l compatibility shim.

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--HdLOThLwLPig1KegWK94f2f4iGiJkdOoe--

--kuQc2vVRG6DCDvTHoiMgLhPGJQc0B6gCC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJW4yTFAAoJEFPuqx0v+F+qqCIIAJfkN2dS1/g4WmVEhMad9yCx
czbzbHY8qpYYcBp6gAIi2bnpn6lsXKvZWKqLkZ595vb4/z3cPBhxhXxHGQZecmLU
zh8czZYdyeQtL01oQibh0buDRX/g3H7ykyD2v08BQuK+Fva4gy6EvSgMsLiFE8O9
0dG6YQau/uE2A7CeHlSeSZwfirTEAKiOVyls61wa/zlpvouL/byC6jcAFYF06icH
ArtI1wFoyAeZxNVQs61lsiqEVebu9swdvqnK5QrXD//aeKDWSuwNVAswo4uJSNUY
BpVbLlg3doFkNVjmt/f2toTr8n6yYB5ShM1FHDHtBGchU9iSZPrm2dnv2hneFUQ=
=Dpxu
-----END PGP SIGNATURE-----

--kuQc2vVRG6DCDvTHoiMgLhPGJQc0B6gCC--

--===============6338061622896799458==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============6338061622896799458==--
