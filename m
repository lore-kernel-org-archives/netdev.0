From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH v2 1/3] ethernet: Add new driver for Marvell Armada 375
 network unit
Date: Tue, 8 Jul 2014 20:40:24 -0300
Message-ID: <20140708234024.GA28830@arch.cereza>
References: <1404561288-11720-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1404561288-11720-2-git-send-email-ezequiel.garcia@free-electrons.com>
 <20140708.152655.619472955292197550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	jason@lakedaemon.net, mw@semihalf.com,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, tawfik@marvell.com,
	alior@marvell.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:42146 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750907AbaGHXlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 19:41:20 -0400
Content-Disposition: inline
In-Reply-To: <20140708.152655.619472955292197550.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08 Jul 03:26 PM, David Miller wrote:
> From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> Date: Sat,  5 Jul 2014 08:54:46 -0300
>=20
> > +module_param(rxq_number, int, S_IRUGO);
> > +module_param(txq_number, int, S_IRUGO);
>=20
> Please don't use module parameters (undocumented ones at that) for th=
ings
> like this.
>=20
> Instead, use or create standard interfaces which other drivers can us=
e as
> well, so that the user interface is consistent for setting things of =
this
> nature regardless of device type.
>=20

Hm... in fact these two parameters should be removed. They are redundan=
t in
this and the mvneta driver. The Rx queue number should be fixed and non=
e of
the drivers support more than 1.

The Tx queue number should be set to the hardware supported one, there'=
s no
reason to use something different.

So, unless someone objects, we'll remove them in v4.

Thanks for the feedback,
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
