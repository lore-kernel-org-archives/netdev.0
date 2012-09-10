From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169: use unlimited DMA burst for TX
Date: Mon, 10 Sep 2012 23:55:21 +0200
Message-ID: <20120910215521.GA930@electric-eye.fr.zoreil.com>
References: <1347234926-5263-1-git-send-email-mschmidt@redhat.com> <20120910.155046.568702072740433838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mschmidt@redhat.com, netdev@vger.kernel.org, hayeswang@realtek.com,
	nic_swsd@realtek.com, ivecera@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58667 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438Ab2IJWM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 18:12:58 -0400
Content-Disposition: inline
In-Reply-To: <20120910.155046.568702072740433838.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> I really need Francois et al. to take a look at this before even thinking
> about applying it.

Hayes tweaked RX_DMA_BURST to an unlimited value one year ago (see
4f6b00e5f139d7be3ca8371b769778f94fa549dd). Other than that, both
RX_DMA_BURST and TX_DMA_BURST have been set at the same (6 i.e. 1024 bytes)
value since the driver was added to the kernel tree.

Realtek's own 8169 driver uses unlimited bursts as well. However their 810x
driver doesn't (whence differing from the kernel driver after 4f6b00).

The current situation is a bit messy to say the least but it does not seem
to match any problem report. I don't have any special "don't".

Hayes, should we:
- mimic Realtek's 8168, 8169 and 810x drivers ?
- always set TX_DMA_BURST at the max value ?
- do something different (per chipset) ?

Thanks.

-- 
Ueimor
