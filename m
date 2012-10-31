From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 06/10] net/macb: clean up ring buffer logic
Date: Wed, 31 Oct 2012 09:48:09 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7081@saturn3.aculab.com>
References: <cover.1351591858.git.nicolas.ferre@atmel.com> <75eb5df193c504e68ebff7d6a6a88d9a1cc678cb.1351591858.git.nicolas.ferre@atmel.com> <AE90C24D6B3A694183C094C60CF0A2F6026B707D@saturn3.aculab.com> <CACiLriQnQcoXFqrqNt3nkY47nR8FnXbqWjtPRp250gueHSMDmQ@mail.gmail.com> <5090F67C.9020104@atmel.com> <5090FFF5.6020109@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <manabian@gmail.com>,
	<patrice.vilchez@atmel.com>, <linux-kernel@vger.kernel.org>,
	<bhutchings@solarflare.com>, <plagnioj@jcrosoft.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>
To: "Nicolas Ferre" <nicolas.ferre@atmel.com>,
	=?Windows-1252?Q?H=E5vard_Skinnemoen?= <havard@skinnemoen.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <5090FFF5.6020109@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 	return (TX_RING_SIZE - (bp->tx_head - bp->tx_tail) & (TX_RING_SIZE - 1));

Is equivalent to:

	return (bp->tx_tail - bp->tx_head) & (TX_RING_SIZE - 1));

	David
