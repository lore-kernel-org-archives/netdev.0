From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Sun, 21 Dec 2014 18:34:24 +0100
Message-ID: <9062978.Vq0rTjKd5z@fuchs>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <9234001.YBqfvtcJFx@fuchs> <5496E135.1@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart10774983.agFPI7KegM"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.18.164]:36994 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751842AbaLURej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2014 12:34:39 -0500
In-Reply-To: <5496E135.1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart10774983.agFPI7KegM
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Sunday 21 December 2014 16:03:17 Arend van Spriel wrote:
> On 12/21/14 15:24, Maximilian Engelhardt wrote:
> > On Sunday 21 December 2014 15:13:50 Arend van Spriel wrote:
> >> On 12/21/14 15:08, Maximilian Engelhardt wrote:
> >>> On Sunday 21 December 2014 11:12:40 Arend van Spriel wrote:
> >>>> On 12/21/14 10:58, Michael Tokarev wrote:
> >>>>> 16.12.2014 19:51, Arend van Spriel wrote:
> >>>>>> Hmm. The function brcms_btc_ecicoex_enab() is calling itself. Please
> >>>>>> remove that call as it causes endless recursion and eventually
> >>>>>> reboot.>
> >>>>> 
> >>>>> Ok, that was easy.  Now it loads, but wifi link still
> >>>>> does not work, stalling as before.  What we're looking
> >>>>> at now?
> >>>> 
> >>>> The patch is just to provide me with extra bt-coex related information
> >>>> in the kernel log. So if you can provide that to me I have to info
> >>>> needed to look in the proprietary code base to determine what is
> >>>> missing.
> >>>> 
> >>>> Regards,
> >>>> Arend
> >>> 
> >>> Hi Arend,
> >> 
> >>> here is the output from my card:
> >> Thanks. It shows you have have the same bt-coex version as Michael. I am
> >> not familiar with bluetooth side of things. Are you both using bluetooth
> >> on 4313?
> >> 
> >> Regards,
> >> Arend
> > 
> > I don't know. I think I have Bluetooth somehow enabled but I'm not really
> > using it. I definitely don't have any Bluetooth devices connected. I could
> > try to unload/disable Bluetooth it to see if it makes any difference.
> 
> That would be useful to know.
> 

I did a test with all Bluetooth modules unloaded that I could find but 
throughput was still very low (about 4 Mbit/s with brcmsmac, my atheros USB 
stick archived about 110 Mbit/s).

Greetings,
Maxi

--nextPart10774983.agFPI7KegM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUlwSjAAoJEIHqZH0kK9IV/2YQALtyTrDLsb2b7yVKU+A7GOdm
tTEjJVtZYwn1/IiNVr0gpZMsKRrqXjHfwy6EYOqNHtmbifFttz6kMlCMT95Okb+w
luvkT5n1KmxOMiyxiNMXMFR/BpN6/Ml15R33Gpm/jldTF55saGiPXsHUhpQHS8uU
sqmEb+eMw/aJKbU6OSVOjLFTBB99Fgak7VQhuQ4YDB6UOscuJZJYRbdC7g5HgMMC
ixG9mBB9DSfmLk9TUz9yMNuP8Io2SyiPdfxjQbgOGuru2YgcZWjmhO62+Z7D0Y1i
xcSTxcKYjiejULPiwtDD/QuE0XLhvFPNOseT94j8JDtCE1i4OozHyYX6Io4FxLn0
wp2cKVBDPjoLm+RGmiI1+PNG1p81vmZUat9bcuL7tS5oL3Jpz6XaIPNbAZlv7sP4
kIkL63QYhs7ZOJv8kEmfZX9NyVP24MNSUsAm3dR918ZnVQlN8N3hZpZsmbeZoB90
UF9mieWuUW0lg1K7NPsFt9a8OrYMfDkUNcAQE479hkfO8O8iBpQAt+752WfoUpOg
1sO23FEnVGVANwYRIFYiPaUrRNqcq3XC0Rh/pSl9wSFHOYt/qt4XD4yXWr3CAaPz
gDLGRvPNgxyQlE6nLVeZ4i8cJOO5PVnBrpmHiKawuwTLzrwrYqEMZuzNsyAcwyLh
RJI2LK6jn8/OhzNjs7hB
=PLx/
-----END PGP SIGNATURE-----

--nextPart10774983.agFPI7KegM--
