From: Wolfgang Walter <linux@stwm.de>
Subject: Re: linux 3.13: problems with isatap tunnel device and UFO
Date: Tue, 11 Feb 2014 18:42:36 +0100
Message-ID: <5911515.kv7YDRiZP1@h2o.as.studentenwerk.mhn.de>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de> <1581659.JtJ1UQaXJr@h2o.as.studentenwerk.mhn.de> <20140211024403.GE11150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:52094 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750978AbaBKRmi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Feb 2014 12:42:38 -0500
In-Reply-To: <20140211024403.GE11150@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 11. Februar 2014, 03:44:03 schrieb Hannes Frederic Sowa:
> On Sun, Feb 09, 2014 at 12:17:15AM +0100, Wolfgang Walter wrote:
> > host A (which shows the problem with kernel 3.13):
> >=20
> > $ ip addr ls eth0
> > 4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fas=
t state
> > UP group default qlen 1000
> >=20
> >     link/ether 11:22:33:44:55:66 brd ff:ff:ff:ff:ff:ff
> >     inet 192.168.1.1/24 brd 192.168.1.255 scope global eth0
> >        valid_lft forever preferred_lft forever
> >     inet6 2001:1111:2222:aaaa:0:5efe:c0a8:101/120 scope global
> >        valid_lft forever preferred_lft forever
> >     inet6 fe80::1322:33ff:fe44:5566/64 scope link
> >        valid_lft forever preferred_lft forever
>=20
> What driver does this interface use?
>=20
> ethtool -i eth0
>=20

driver: r8169
version: 2.3LK-NAPI
firmware-version: rtl_nic/rtl8168e-1.fw
bus-info: 0000:05:00.0
supports-statistics: yes
supports-test: no
supports-eeprom-access: no
supports-register-dump: yes
supports-priv-flags: no

I see this also with another machine, here it is

driver: forcedeth
version: 0.64
firmware-version:=20
bus-info: 0000:00:0a.0
supports-statistics: yes                                               =
        =20
supports-test: yes
supports-eeprom-access: no
supports-register-dump: yes
supports-priv-flags: no


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
