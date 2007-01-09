From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: Using 802.11x wireless usb device on MIPS platform
Date: Tue, 9 Jan 2007 13:52:50 -0500
Message-ID: <200701091352.54273.flamingice@sourmilk.net>
References: <1cf601c73399$2ab7cd10$106215ac@realtek.com.tw> <20070109140931.GB6614@linux-mips.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1544725.6kS19maBtC";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:37002 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932373AbXAISx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 13:53:27 -0500
To: colin <colin@realtek.com.tw>
In-Reply-To: <20070109140931.GB6614@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1544725.6kS19maBtC
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 09 January 2007 09:09, Ralf Baechle wrote:
> On Tue, Jan 09, 2007 at 10:52:14AM +0800, colin wrote:
> > I have used two 802.11x wireless usb devices successfully on MIPS
> > platform. One is realtek 8187 and the other one is ralink 2571.
> > I would like to put them into kernel tree and then I found that there a=
re
> > not many 802.11x devices supported in Linux.
>
Please see the wireless-dev tree. There is a driver for the ralink 2571 in=
=20
there which will be merged along with a number of other wireless drivers wh=
en=20
the devicescape 802.11 (d80211) wireless stack is sufficiently polished. Ne=
w=20
softmac wireless drivers should be based on that stack if possible. I am=20
working on a d80211 version of the rtl8187/rtl8185 driver right now, which =
is=20
I think is the last linux 802.11g driver which needs to be ported.

=2DMichael Wu

--nextPart1544725.6kS19maBtC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFo+SGT3Oqt9AH4aERAiKcAJ9Ua4Wl3GTfo3nL1hI3QtXUrKrFTQCgsdJU
iMtgf0yzbkZqB1OitK0m76Y=
=z9X/
-----END PGP SIGNATURE-----

--nextPart1544725.6kS19maBtC--
