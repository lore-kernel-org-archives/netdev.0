From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v4 4/9] bgmac: simplify rx DMA error handling
Date: Mon, 13 Apr 2015 16:53:46 +0200
Message-ID: <CACna6rwFcg0AKa=2h7Fg9kNZdtFY8vBNNVwXi67Bvga0v3YU0w@mail.gmail.com>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org>
	<1428933162-26763-4-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:32972 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753908AbbDMOxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:53:46 -0400
Received: by iebmp1 with SMTP id mp1so66687749ieb.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 07:53:46 -0700 (PDT)
In-Reply-To: <1428933162-26763-4-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 April 2015 at 15:52, Felix Fietkau <nbd@openwrt.org> wrote:
> Unmap the DMA buffer before checking it. If it is poisoned, map it again
> and pass it back to the hardware.

Where exactly do you map it again? I can't see it. It's not handled in
bgmac_dma_rx_setup_desc. Also keep in mind that mapping may fail -
this is why old code doesn't unmap anything until a new buffer is
really ready. How do you want to deal with mapping error after
unmapping a buffer?
