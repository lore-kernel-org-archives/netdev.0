From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH v2 net] ipv6: addrconf: fix Juniper SSL VPN client regression
Date: Mon, 11 Jul 2016 12:59:16 -0400
Message-ID: <7461.1468256356@turing-police.cc.vt.edu>
References: <1468248230-5763-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1468256356_4649P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jonas Lippuner <jonas@lippuner.ca>,
	=?iso-8859-1?Q?=5409=85E4=82F1=660E?=
	<hideaki.yoshifuji@miraclelinux.com>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.smtp.vt.edu ([198.82.183.121]:40082 "EHLO
	omr2.cc.vt.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932201AbcGKQ7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 12:59:30 -0400
In-Reply-To: <1468248230-5763-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1468256356_4649P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, 11 Jul 2016 16:43:50 +0200, Bj=F8rn Mork said:

> Link: https://bugzilla.kernel.org/show_bug.cgi?id=3D121131
> Fixes: cc9da6cc4f56 (=22ipv6: addrconf: use stable address generator fo=
r ARPHRD
_NONE=22)
> Reported-by: Valdis Kletnieks <Valdis.Kletnieks=40vt.edu>
> Reported-by: Jonas Lippuner <jonas=40lippuner.ca>
> Suggested-by: Hannes Frederic Sowa <hannes=40stressinduktion.org>
> Cc: 吉藤英明 <hideaki.yoshifuji=40miraclelinux.com>
> Signed-off-by: Bj=F8rn Mork <bjorn=40mork.no>
> ---
> v2 changes:
>  - added a netdevice private flag to suppress automatic IPv6 LL
>  - suppressing only for =22tun=22 devices

Tested against next-20160708, and the Juniper code works fine. Feel free
to stick a Tested-By: on the V2 patch...

--==_Exmh_1468256356_4649P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBV4PQZAdmEQWDXROgAQK/1g//S/MDWHMroeQ/4Zl9vmltoPqW7LFbegat
Wy+HxNXDcXvpbfFgQknlANfIXh0ntQlhRYNK0gi+Fk/28qTPjUTgnEL5R27a4Ioa
jASeftkaAFCrN6JbkvnVJyUllSg/D2p8WhiwLpjo80d6CZ9Eq1SqgB0DZYlIFTkv
eNqijzeHcJ1i7F1oC+iLR96ZWLfJhVr0tk3gPpmfO5uf29fVEk5rIfeTEZyJ0u9Q
l1ryb02FDcbCtQtXoNii+237kNA5DPxQtJR5Ok+TyQjyOsSTESxOOhvtJbt8cppk
eHMILazMI6yYD+hB4XJIbc4w6NJnCearz+BEGJrBSq6hBSIJ+IOoEe2O5uihK9ri
L06tD8H7TOvM/JMpB0oHlhQE996UuhtyhDyDHmOf6emzTNB8gG1i1eushphEGimx
/XzA9U8CyxJjKDXLOuDazpFRNYA8YrT1ejxuvSWFQlQEA75gVvyYj8R90Z1DJmRd
nTaqjgrlqQp7pIhcDTPLHabH1J6US4nXxVM3jhS61WSeRgPl6obdO3ncozFT/Sij
Cts6zcphW9xkAC8KyjPkwvBTwmWq3x69dolHTMiibb24MleokDVhApLpzMCFMM51
CXLPx/ery93dl4ygk25SYKqSlrxlXFLt2+H/gCcnMSgvQbVPwfHugbqr7j2mYjL1
19DbYum6ZIQ=
=STc6
-----END PGP SIGNATURE-----

--==_Exmh_1468256356_4649P--
