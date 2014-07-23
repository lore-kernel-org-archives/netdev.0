From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: Re: [PATCH 2/6] net/macb: add scatter-gather hw feature
Date: Wed, 23 Jul 2014 09:45:12 +0200
Message-ID: <53CF6808.4070206@atmel.com>
References: <cover.1405689937.git.cyrille.pitchen@atmel.com>	<fda3a504240e1f6863107ef6bf1e78586671a030.1405689937.git.cyrille.pitchen@atmel.com> <20140720.211337.211665722122921773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nicolas.ferre@atmel.com>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <soren.brinkmann@xilinx.com>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140720.211337.211665722122921773.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 21/07/2014 06:13, David Miller a =E9crit :
> From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
> Date: Fri, 18 Jul 2014 16:21:14 +0200
>=20
>> +		if (tx_skb->mapped_as_page) {
>> +			dma_unmap_page(&bp->pdev->dev, tx_skb->mapping,
>> +				       tx_skb->size, DMA_TO_DEVICE);
>> +		} else {
>> +			dma_unmap_single(&bp->pdev->dev, tx_skb->mapping,
>> +					 tx_skb->size, DMA_TO_DEVICE);
>> +		}
>=20
> Please do not use curly braces for basic block composed of a single s=
tatement.
>=20
Hi David,

thanks for your review, I'll fix it in the next series of patch.

Regards,

Cyrille
