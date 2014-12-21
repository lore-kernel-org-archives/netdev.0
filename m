From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Sun, 21 Dec 2014 15:24:29 +0100
Message-ID: <9234001.YBqfvtcJFx@fuchs>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <141935691.MGh8oJCUVD@fuchs> <5496D59E.5030601@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2165607.tNvV9YbdjW"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.18.164]:44792 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058AbaLUOYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2014 09:24:32 -0500
In-Reply-To: <5496D59E.5030601@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart2165607.tNvV9YbdjW
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Sunday 21 December 2014 15:13:50 Arend van Spriel wrote:
> On 12/21/14 15:08, Maximilian Engelhardt wrote:
> > On Sunday 21 December 2014 11:12:40 Arend van Spriel wrote:
> >> On 12/21/14 10:58, Michael Tokarev wrote:
> >>> 16.12.2014 19:51, Arend van Spriel wrote:
> >>>> Hmm. The function brcms_btc_ecicoex_enab() is calling itself. Please
> >>>> remove that call as it causes endless recursion and eventually reboot.>
> >>> 
> >>> Ok, that was easy.  Now it loads, but wifi link still
> >>> does not work, stalling as before.  What we're looking
> >>> at now?
> >> 
> >> The patch is just to provide me with extra bt-coex related information
> >> in the kernel log. So if you can provide that to me I have to info
> >> needed to look in the proprietary code base to determine what is missing.
> >> 
> >> Regards,
> >> Arend
> > 
> > Hi Arend,
> 
> > here is the output from my card:
> Thanks. It shows you have have the same bt-coex version as Michael. I am
> not familiar with bluetooth side of things. Are you both using bluetooth
> on 4313?
> 
> Regards,
> Arend

I don't know. I think I have Bluetooth somehow enabled but I'm not really 
using it. I definitely don't have any Bluetooth devices connected. I could try 
to unload/disable Bluetooth it to see if it makes any difference.

Greetings,
Maxi


--nextPart2165607.tNvV9YbdjW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUltgdAAoJEIHqZH0kK9IVq08P/3+pOrkLsDb4JbRN3+M9klXr
Oj+R9rl7PglaE7ADWwZWHdwJuacC/aUQEBEof4/WT7xyPDGIepfPguXSA0pHhyDR
y4z6O1xeMLijlooVKto8b/6A6V04WJQ0IEDBef6gtYNGaQlIyo2jVTqqbtU4Exlu
4tRnPkMvFQLV1LFQMDYTicn/ODqEjqsguVlorwui47cJso2xu5LngWB0re1ihEOS
V2K+2CTN0WNfY1QQEWNU9La5cvDdW+tzXF/sMAZNvwQmDx2CrfBCnBiUvKdr34kt
km5c7f1GgGKV3Eqp2Y65oRGB3bhdItOwlt/I8rpa2dZLUMVEoK2FAP9fO+PyOffq
crZ+VU+EGp7lZ1CgcuDycefyjc4UHrs2GLFJ7jqT+9Okl7XwhNFRaxr7fwXnl3jt
PEMsmGcjbaD6imiwhahDQyffUy84T9K++DfDLwZkhQr+frjKPZAMMgi++IqRAhBD
SoNLQ4YtpvqQPnV8GyiyE1FxIco3lZzY7ntx5wM9IG2qmH5OzRgXhyJhHcz7fT8n
upAcU615EI33uP2NRfZMegyOP6uU78KP1/pGo0vrsvqqe0a7U7vNKFLcnU/Cu8Zz
+nV3P2An/4/E412CYY58K/eLTKxDBpBgQ5yTpCcbl69SXMXbTuYQ3nKuCWn5HM1T
jDfJuKahssXm68eVg/FQ
=RurE
-----END PGP SIGNATURE-----

--nextPart2165607.tNvV9YbdjW--
