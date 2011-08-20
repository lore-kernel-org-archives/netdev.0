From: David Miller <davem@davemloft.net>
Subject: Re: inetd and Linux kernel 3.0
Date: Sat, 20 Aug 2011 16:33:12 -0700 (PDT)
Message-ID: <20110820.163312.1686705823210711719.davem@davemloft.net>
References: <4e503565.28b8ec0a.650c.5823@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: fragabr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196Ab1HTXdS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 19:33:18 -0400
In-Reply-To: <4e503565.28b8ec0a.650c.5823@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: D=E2niel Fraga <fragabr@gmail.com>
Date: Sat, 20 Aug 2011 19:29:54 -0300

> 	Hi, I upgraded to Linux kernel 3.0 and now I have the following
> message on the log:
>=20
> Aug 19 23:22:13 tux inetd[3143]: nntp/tcp: bind: Address family not
> supported by protocol
>=20
> 	With kernel 2.6.39 everything worked fine. Is it a problem with
> inetd? Maybe some incompatibility?

It is trying to bind to an ipv6 address using an ipv4 socket.

