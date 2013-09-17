From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: implement unaligned addressing for DMA rings
 that support it
Date: Mon, 16 Sep 2013 21:31:35 -0400 (EDT)
Message-ID: <20130916.213135.1916519693990322668.davem@davemloft.net>
References: <1379279598-25274-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hauke@hauke-m.de
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946Ab3IQBbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:31:36 -0400
In-Reply-To: <1379279598-25274-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Sun, 15 Sep 2013 23:13:18 +0200

> This is important patch for new devices that support unaligned
> addressing. That devices suffer from the backward-compatibility bug i=
n
> DMA engine. In theory we should be able to use old mechanism, but in
> practice DMA address seems to be randomly copied into status register
> when hardware reaches end of a ring. This breaks reading slot number
> from status register and we can't use DMA anymore.
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied.
