From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH v4 4/9] bgmac: simplify rx DMA error handling
Date: Mon, 13 Apr 2015 17:05:38 +0200
Message-ID: <552BDB42.1080104@openwrt.org>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org>	<1428933162-26763-4-git-send-email-nbd@openwrt.org> <CACna6rwFcg0AKa=2h7Fg9kNZdtFY8vBNNVwXi67Bvga0v3YU0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:46397 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932228AbbDMPFx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 11:05:53 -0400
In-Reply-To: <CACna6rwFcg0AKa=2h7Fg9kNZdtFY8vBNNVwXi67Bvga0v3YU0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-13 16:53, Rafa=C5=82 Mi=C5=82ecki wrote:
> On 13 April 2015 at 15:52, Felix Fietkau <nbd@openwrt.org> wrote:
>> Unmap the DMA buffer before checking it. If it is poisoned, map it a=
gain
>> and pass it back to the hardware.
>=20
> Where exactly do you map it again? I can't see it. It's not handled i=
n
> bgmac_dma_rx_setup_desc. Also keep in mind that mapping may fail -
> this is why old code doesn't unmap anything until a new buffer is
> really ready. How do you want to deal with mapping error after
> unmapping a buffer?
You're right, seems that I accidentally dropped a chunk of the patch.

- Felix
