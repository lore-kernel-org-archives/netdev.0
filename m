From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Possible bug with r8169 driver
Date: Sat, 29 Sep 2012 09:20:28 +0200
Message-ID: <20120929072028.GA3730@electric-eye.fr.zoreil.com>
References: <2197741.c8FeV4Xbis@bureau> <20120927222147.GA29047@electric-eye.fr.zoreil.com> <1478421.GOy9qdQlkG@bureau>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Nolwenn <donolwenn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49790 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175Ab2I2Hjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2012 03:39:36 -0400
Content-Disposition: inline
In-Reply-To: <1478421.GOy9qdQlkG@bureau>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nolwenn <donolwenn@gmail.com> :
> Le vendredi 28 septembre 2012 00:21:47 Francois Romieu a =C3=A9crit :
[...]
> > Can you send an 'ip -s link' before any ipv6 traffic flows, then
> > after ?
>=20
> Before ipv6 traffic
>=20
> % ip -s link

/me plugs brain and realizes that the driver does not update the device
stats multicast field.

The multicast stats will appear in the output of 'ethtool -S eth0'.

Can you send two complete binary tcpdump captures (w/o -p option) in th=
e
same contexts ?

Don't bother obfuscating the ipv6 address if it equals the one appearin=
g
in the mail headers.

[RTL8168f/8111f]
> > Hayes, is there by any luck something different for the 8168f regar=
ding
> > the layout of the multicast filtering registers ?
>=20
> I don't have sufficient skills in networks to understand what do you =
mean,=20
> sorry. Any command line, files comparing to get the information ?

The documentation is scarce to say the least. Hayes can tell if some
register layout change or chipset specifics has gone unnoticed.

--=20
Ueimor
