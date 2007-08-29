From: James Chapman <jchapman@katalix.com>
Subject: Re: malformed captured packets
Date: Wed, 29 Aug 2007 08:35:24 +0100
Message-ID: <46D521BC.1050300@katalix.com>
References: <200708281811.34074.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:41510 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092AbXH2Hf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 03:35:27 -0400
In-Reply-To: <200708281811.34074.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Toralf F=F6rster wrote:
> I use at home an DSL connection (stable Gentoo system),
> current kernel is 2.6.22-gentoo-r5.
>=20
> I attached 2 pcap files with the communication of the KDE program ksc=
d with the
> CDDB server freedb.org, sniffed from interface ppp0 and eth0 respecti=
vely.
>=20
> The sniffed network stream over the ppp0 interface looks _always_ fin=
e whereas
> the sniffed packets from the eth0 always looks bad :-(
>=20
> I don't undestand why the ppp0 stream is ok, whereas the eth0 stream =
has always
> a malformed package (eg #13 in kscd_eth0.pcap) which contains the con=
tent of the CD.
> And I'm really confused about the fact, that within a LAN I did not h=
ave a
> malformed packet.
>=20
> I discussed it
> here http://www.wireshark.org/lists/wireshark-users/200707/msg00187.h=
tml
> and here http://bugzilla.kernel.org/show_bug.cgi?id=3D8793 and many d=
ifferent
> places in the past but w/o success.
>=20
> Any explanation are appreciated.

Can you provide more information about the problem, please? Are you=20
using a simple DSL modem with PPPoE, such that the ppp0 interface is=20
that of the pppd started by a local PPPoE server? Is this a problem onl=
y=20
with packet capture or are you seeing actual data corruption? Did this=20
work with previous kernels? What is the network topology related to the=
=20
DSL interface?

--=20
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

