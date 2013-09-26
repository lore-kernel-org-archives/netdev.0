From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] via-rhine: fix VLAN priority field (PCP, IEEE 802.1p)
Date: Thu, 26 Sep 2013 16:09:45 -0400 (EDT)
Message-ID: <20130926.160945.87536599796828898.davem@redhat.com>
References: <20130921122411.GA25499@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, peter.bostrom@netrounds.com
To: rl@hellgate.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9306 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753279Ab3IZUJw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 16:09:52 -0400
In-Reply-To: <20130921122411.GA25499@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Roger Luethi <rl@hellgate.ch>
Date: Sat, 21 Sep 2013 14:24:11 +0200

> From: Roger Luethi <rl@hellgate.ch>
>=20
> Outgoing packets sent by via-rhine have their VLAN PCP field off by o=
ne
> (when hardware acceleration is enabled). The TX descriptor expects on=
ly VID
> and PCP (without a CFI/DEI bit).
>=20
> Peter Bostr=F6m noticed and reported the bug.
>=20
> Signed-off-by: Roger Luethi <rl@hellgate.ch>

Applied, thanks.
