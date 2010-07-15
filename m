From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix a buffer overflow in
 bonding_show_queue_id.
Date: Wed, 14 Jul 2010 18:25:05 -0700 (PDT)
Message-ID: <20100714.182505.115922952.davem@davemloft.net>
References: <1279146277-9381-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bonding-devel@lists.sourceforge.net, andy@greyhouse.net,
	fubar@us.ibm.com, netdev@vger.kernel.org
To: nicolas.2p.debian@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41654
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758098Ab0GOBYt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 21:24:49 -0400
In-Reply-To: <1279146277-9381-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Date: Thu, 15 Jul 2010 00:24:37 +0200

> The test for buffer overflow ensures we have room for 6 more bytes.
> sprintf, called with %s:%d, slave->dev->name, slave->queue_id may yie=
ld
> far more than 6 bytes.
>=20
> The correct test is res > (PAGE_SIZE - IFNAMSIZ - 6) .
>=20
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Applied to net-next-2.6, thanks.
