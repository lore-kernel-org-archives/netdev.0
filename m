From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] [v3] PA Semi PWRficient Ethernet driver
Date: Wed, 31 Jan 2007 10:38:06 -0800
Message-ID: <20070131103806.29fc8d2e@freekitty>
References: <20070129060852.GA7814@lixom.net>
	<20070130014434.GC18935@lixom.net>
	<20070131054457.GA32043@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	Christoph Hellwig <hch@infradead.org>
To: olof@lixom.net (Olof Johansson)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42411 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030551AbXAaSlH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 13:41:07 -0500
In-Reply-To: <20070131054457.GA32043@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

O
> +static noinline void pasemi_mac_free_tx_resources(struct net_device *dev)

Why tell compiler how to do it's job.  marking it noinline?

> Index: merge/drivers/net/pasemi_mac.h
> ===================================================================
> --- /dev/null
> +++ merge/drivers/net/pasemi_mac.h
					 PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT_M)
> +
> +struct pas_dma_xct_descr {
> +	union {
> + 		u64	mactx;
> +#define	XCT_MACTX_T		0x8000000000000000
> +#define	XCT_MACTX_ST		0x4000000000000000
> +#define XCT_MACTX_NORES		0x0000000000000000
> +#define XCT_MACTX_8BRES		0x1000000000000000
> +#define XCT_MACTX_24BRES	0x2000000000000000
> +#define XCT_MACTX_40BRES	0x3000000000000000
> +#define XCT_MACTX_I		0x0800000000000000
> +#define XCT_MACTX_O		0x0400000000000000
> +#define XCT_MACTX_E		0x0200000000000000
> +#define XCT_MACTX_VLAN_M	0x0180000000000000
> +#define XCT_MACTX_VLAN_NOP	0x0000000000000000
> +#define XCT_MACTX_VLAN_REMOVE	0x0080000000000000
> +#define XCT_MACTX_VLAN_INSERT   0x0100000000000000
> +#define XCT_MACTX_VLAN_REPLACE  0x0180000000000000
> +#define XCT_MACTX_CRC_M		0x0060000000000000
> +#define XCT_MACTX_CRC_NOP	0x0000000000000000
> +#define XCT_MACTX_CRC_INSERT	0x0020000000000000
> +#define XCT_MACTX_CRC_PAD	0x0040000000000000
> +#define XCT_MACTX_CRC_REPLACE	0x0060000000000000
> +#define XCT_MACTX_SS		0x0010000000000000
> +#define XCT_MACTX_LLEN_M	0x00007fff00000000
> +#define XCT_MACTX_LLEN_S	32ull
> +#define XCT_MACTX_LLEN(x)	((((long)(x)) << XCT_MACTX_LLEN_S) & XCT_MACTX_LLEN_M)
> +#define XCT_MACTX_IPH_M		0x00000000f8000000
> +#define XCT_MACTX_IPH_S		27ull
> +#define XCT_MACTX_IPH(x)	((((long)(x)) << XCT_MACTX_IPH_S) & XCT_MACTX_IPH_M)
> +#define XCT_MACTX_IPO_M		0x0000000007c00000
> +#define XCT_MACTX_IPO_S		22ull
> +#define XCT_MACTX_IPO(x)	((((long)(x)) << XCT_MACTX_IPO_S) & XCT_MACTX_IPO_M)
> +#define XCT_MACTX_CSUM_M	0x0000000000000060
> +#define XCT_MACTX_CSUM_NOP	0x0000000000000000
> +#define XCT_MACTX_CSUM_TCP	0x0000000000000040
> +#define XCT_MACTX_CSUM_UDP	0x0000000000000060
> +#define XCT_MACTX_V6		0x0000000000000010
> +#define XCT_MACTX_C		0x0000000000000004
> +#define XCT_MACTX_AL2		0x0000000000000002
> +		u64	macrx;

Mixing definitions and structure values gets confusing.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
