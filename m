From: James Chapman <jchapman@katalix.com>
Subject: Re: bridging with gre tunnel
Date: Mon, 14 Jul 2008 10:13:49 +0100
Message-ID: <487B18CD.5020502@katalix.com>
References: <4876FDF0.1030807@iki.fi> <487AA0CD.9090600@snapgear.com> <487AFF82.4090707@iki.fi> <487B11D9.7090800@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:42904 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755939AbYGNJOI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 05:14:08 -0400
In-Reply-To: <487B11D9.7090800@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Philip Craig wrote:
> Timo Ter=E4s wrote:
> I posted a cleaner version that's similar to what the old patch
> did, see http://marc.info/?l=3Dlinux-netdev&m=3D115449948503549&w=3D2
>=20
> But I don't think that is the right approach:
> - it forces you to use bridging if you only want ethernet over GRE
> - the change fundamentally has nothing to do with bridging

I agree.

> It could be a new device that sits on top of GRE and simply does
> ethernet encapsulation then passes it to the raw GRE device.

This would be my preferred approach. There are other drivers that use a=
=20
netdev to do some encap/decap processing on packets which are then=20
passed on to another driver, e.g. macvlan, and it works well.

--=20
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

