From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tigon3 firmware problem with 2.6.30-rc8
Date: Tue, 09 Jun 2009 17:46:17 +0200
Message-ID: <4A2E83C9.6020600@gmail.com>
References: <BAY103-DAV11DE7A52D38E0062B2275DB2440@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47671 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbZFIPqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:46:22 -0400
In-Reply-To: <BAY103-DAV11DE7A52D38E0062B2275DB2440@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi a =E9crit :
> Hi folks,
>=20
> I have a problem with a 3 years old notebook NIC,
> tg3 with linux 2.6.29.4 and 2.6.30-rc8.
> When I modprobe tg3 all is fine. When I issue
> 'ifconfig eth0 1.1.1.1' I get this message:
>=20
> tg3 0000:02:0e.0: firmware: requesting tigon/tg3_tso5.bin
> eth0: Failed to load firmware "tigon/tg3_tso5.bin"
> eth0: TSO capability disabled.
> tg3 0000:02:0e.0: PME# disabled
> tg3: eth0: Link is up at 100 Mbps, full duplex.
> tg3: eth0: Flow control is off for TX and off for RX
>=20
> This is the output from ls -l /lib/firmware/tigon:
>=20
> root@Ghawar:~# ls -l /lib/firmware/tigon
> total 16
> -rw-r--r-- 1 root root 2668 2009-06-09 17:18 tg3.bin
> -rw-r--r-- 1 root root 7004 2009-06-09 17:18 tg3_tso.bin
> -rw-r--r-- 1 root root 3884 2009-06-09 17:18 tg3_tso5.bin
> root@Ghawar:~#
>=20
> However the nic is working.
>=20
> Any feed-back are welcome,
> TIA
>=20

You could try to set CONFIG_FIRMWARE_IN_KERNEL=3Dy in your .config

