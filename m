From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V5] bgmac: driver for GBit MAC core on BCMA bus
Date: Tue, 08 Jan 2013 17:55:20 -0800 (PST)
Message-ID: <20130108.175520.708710866856394716.davem@davemloft.net>
References: <1357626888-2375-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, joe@perches.com
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756523Ab3AIBzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 20:55:21 -0500
In-Reply-To: <1357626888-2375-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Tue,  8 Jan 2013 07:34:48 +0100

> BCMA is a Broadcom specific bus with devices AKA cores. All recent BC=
MA
> based SoCs have gigabit ethernet provided by the GBit MAC core. This
> patch adds driver for such a cores registering itself as a netdev. It
> has been tested on a BCM4706 and BCM4718 chipsets.
>=20
> In the kernel tree there is already b44 driver which has some common
> things with bgmac, however there are many differences that has led to
> the decision or writing a new driver:
> 1) GBit MAC cores appear on BCMA bus (not SSB as in case of b44)
> 2) There is 64bit DMA engine which differs from 32bit one
> 3) There is no CAM (Content Addressable Memory) in GBit MAC
> 4) We have 4 TX queues on GBit MAC devices (instead of 1)
> 5) Many registers have different addresses/values
> 6) RX header flags are also different
>=20
> The driver in it's state is functional how, however there is of cours=
e
> place for improvements:
> 1) Supporting more net_device_ops
> 2) SUpporting more ethtool_ops
> 3) Unaligned addressing in DMA
> 4) Writing separated PHY driver
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

This patch doesn't apply to the net-next tree, please re-spin.
