From: Joe Perches <joe@perches.com>
Subject: Re: [RFC][PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Thu, 13 Dec 2012 17:21:15 -0800
Message-ID: <1355448075.13796.47.camel@joe-AO722>
References: <1355420611-25764-1-git-send-email-zajec5@gmail.com>
	 <1355424373.13796.25.camel@joe-AO722>
	 <CACna6rwJZpjdyWjkdoLrcyo3+Pq8CCk4x1N5GS+n8P5prBVm2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35835 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753031Ab2LNBVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 20:21:15 -0500
In-Reply-To: <CACna6rwJZpjdyWjkdoLrcyo3+Pq8CCk4x1N5GS+n8P5prBVm2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-13 at 20:24 +0100, Rafa=C5=82 Mi=C5=82ecki wrote:
> 2012/12/13 Joe Perches <joe@perches.com>:
> > On Thu, 2012-12-13 at 18:43 +0100, Rafa=C5=82 Mi=C5=82ecki wrote:
> >> BCMA is a Broadcom specific bus with devices AKA cores. All recent=
 BCMA
> >> based SoCs have gigabit ethernet provided by the GBit MAC core. Th=
is
> >> patch adds driver for such a cores registering itself as a netdev.=
 It
> >> has been tested on a BCM4706 and BCM4718 chipsets.
[]
> >> +     /* Stats */
> >> +     bool stats_grabbed;
> >> +     u32 mib_tx_regs[BGMAC_NUM_MIB_TX_REGS];
> >> +     u32 mib_rx_regs[BGMAC_NUM_MIB_RX_REGS];
> >> +};
> >
> > Maybe some minor reordering of the u8/bools to reduce padding.
>=20
> Really? Compiler won't do that for me? I hope that compiler optimizes
> structs (until using __packed) :(

The compiler is not allowed to reorder struct members.
Perhaps you bundle together all the u8/bools.
Maybe not when/where cachelines are crossed.
