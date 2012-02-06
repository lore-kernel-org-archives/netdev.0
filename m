From: "Henrik Rydberg" <rydberg@euromail.se>
Subject: Re: [PATCH] bcma: don't fail for bad SPROM CRC
Date: Mon, 6 Feb 2012 18:35:32 +0100
Message-ID: <20120206173532.GA5692@polaris.bitmath.org>
References: <1328534801-3477-1-git-send-email-rydberg@euromail.se>
 <CACna6rwqO73a0G=AQhTVCm=KeLRgjgc5ohJ_B8Z4T9Y-6ZTwMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b22.telenor.se ([195.54.99.213]:51297 "EHLO
	smtprelay-b22.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337Ab2BFReI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 12:34:08 -0500
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-b22.telenor.se (Postfix) with ESMTP id 7BDB7EB8C0
	for <netdev@vger.kernel.org>; Mon,  6 Feb 2012 18:34:07 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <CACna6rwqO73a0G=AQhTVCm=KeLRgjgc5ohJ_B8Z4T9Y-6ZTwMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 06, 2012 at 06:08:51PM +0100, Rafa=C5=82 Mi=C5=82ecki wrote=
:
> 2012/2/6 Henrik Rydberg <rydberg@euromail.se>:
> > The brcmsmac driver is now checking the bcma SPROM CRCs, leaving so=
me
> > chipsets unrecognized that were functional prior to the switch. In
> > particular, the current code bails out on recent Macbooks. This pat=
ch
> > simply ignores the outcome of the CRC check, with the argument that=
 an
> > unrecognized SPROM should be treated similarly to a non-existing on=
e.
>=20
> Have you maybe tried to look at the real solution?

No, this is a pure regression fix.

Henrik
