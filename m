From: David Miller <davem@davemloft.net>
Subject: Re: high rate injection and fragmentation
Date: Mon, 09 Feb 2009 15:10:58 -0800 (PST)
Message-ID: <20090209.151058.193026368.davem@davemloft.net>
References: <3f847c820902090720w98e2ca8pc66f55716c030194@mail.gmail.com>
	<Pine.LNX.4.64.0902091806510.31742@wrl-59.cs.helsinki.fi>
	<3f847c820902090918j4da4b94o3eee35415f088afb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: rauhersu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42047
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752264AbZBIXLE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2009 18:11:04 -0500
In-Reply-To: <3f847c820902090918j4da4b94o3eee35415f088afb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ra=FAl Hern=E1ndez <rauhersu@gmail.com>
Date: Mon, 9 Feb 2009 18:18:50 +0100

> Hi Ilpo,
>=20
> Thanks for your answer, I did not know about that feature. Looking at
> my settings:
>=20
> # ethtool -k eth2
> ...
> tcp segmentation offload: on
>=20
> I think ethereal hooks up before reaching the TCP offload which is
> handled by the NIC.

No, the packets will be large as created by the TCP stack,
and then the NIC hardware splits them up as it transmits
them onto the wire.
