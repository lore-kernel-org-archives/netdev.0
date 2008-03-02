From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH 2/2] [IPV6]: Fix source address selection for ORCHID addresses
Date: Sun, 2 Mar 2008 20:11:48 +0200
Message-ID: <200803022011.48294.rdenis@simphalempin.com>
References: <20080221100842.GA24905@verkkotelakka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:44112 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409AbYCBSLx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 13:11:53 -0500
In-Reply-To: <20080221100842.GA24905@verkkotelakka.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Moi,

Le Thursday 21 February 2008 12:08:42 Juha-Matti Tapio, vous avez =E9cr=
it=A0:
> Skip the prefix length matching in source address selection for
> orchid -> non-orchid addresses.
>
> Overlay Routable Cryptographic Hash IDentifiers (RFC 4843,
> 2001:10::/28) are currenty not globally reachable. Without this
> check a host with an ORCHID address can end up preferring those over
> regular addresses when talking to other regular hosts in the 2001::/1=
6
> range thus breaking non-orchid connections.

This is not really a "kernel" issue, but did you consider fixing glibc =
as=20
well, as it needs to replicate source address selection as well in=20
getaddrinfo()? There you will not only have problems with Rule 8, but=20
possibly also with Rule 2 as you will have to take IPv4 addresses into=20
account: e.g. http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D468801

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
