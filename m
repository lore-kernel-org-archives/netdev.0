From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3 v3] net/macb: Try to optimize struct macb layout
Date: Wed, 15 May 2013 10:37:22 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B723A@saturn3.aculab.com>
References: <cover.1368608928.git.nicolas.ferre@atmel.com> <d0bc206ace3baaf681e111ba07c4d0b576839bb4.1368608928.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	"Jean-Christophe PLAGNIOL-VILLARD" <plagnioj@jcrosoft.com>,
	<hein_tibosch@yahoo.es>, <s.trumtrar@pengutronix.de>,
	<michal.simek@xilinx.com>, <monstr@monstr.eu>,
	"Havard Skinnemoen" <havard@skinnemoen.net>
To: "Nicolas Ferre" <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <d0bc206ace3baaf681e111ba07c4d0b576839bb4.1368608928.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Havard Skinnemoen <havard@skinnemoen.net>

> Move the NAPI struct below that since it is used
> from the interrupt handler. This field is also marked as
> ___cacheline_aligned_in_smp.

Is that a good idea if the cache line size is 256 bytes?
Indeed is that ever sane - except for a few special structures
that really need it, and are guaranteed to be allocated
with that much alignment.

	David
