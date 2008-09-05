From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: "Listenless" TCP over =?UTF-8?Q?NAT=3F?=
Date: Fri, 05 Sep 2008 14:51:17 +0200
Message-ID: <5f1c7b80099fb4aa3ad56e830aa525d1@chewa.net>
References: <WorldClient-F200809051345.AA45130148@butn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>,
	Linux Networking <linux-net@vger.kernel.org>
To: xerces8 <xerces8@butn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:40894 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751820AbYIEMvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 08:51:18 -0400
In-Reply-To: <WorldClient-F200809051345.AA45130148@butn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 05 Sep 2008 13:45:13 +0200, "xerces8" <xerces8@butn.net> wrote:=
=0D
> Recently someone mentioned on this (or maybe other...) list a seldom =
used=0D
> technique of establishing a TCP connection without one host listening=
 on=0D
a=0D
> port, but but acting as "clients" and connecting to the peers port.=0D
>=0D
> My question: Can this be used to establish a TCP connection between t=
wo=0D
> hosts that are both behind a (P)NAT router ?=0D
=0D
Linux TCP/IP does allow this at the end nodes.=0D
=0D
However, whether it works on the NAT model. Many NAPT and firewalling b=
oxes=0D
will reset the TCP session if you try to do TCP simultaneous open. Besi=
des,=0D
you need to be able to predict your source port number, which again is =
not=0D
always possible depending on the NAPT implementation.=0D
=0D
=0D
As far as I can tell, this is simply way too failure prone in real life=
=2E=0D
Using some form of UDP encapsulation, such as ICE, Teredo, IPsec-in-UDP=
,=0D
etc works A LOT better, although not always either.=0D
=0D
--=0D
R=C3=A9mi Denis-Courmont

