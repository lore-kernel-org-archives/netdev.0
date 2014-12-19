From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet adapters
Date: Fri, 19 Dec 2014 22:14:50 +0100
Message-ID: <5494954A.8020705@gmx.de>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com> <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:55031 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751384AbaLSVPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 16:15:06 -0500
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.12.2014 04:25, Raghu Vatsavayi wrote:
> 		desc_ring[i].info_ptr =
> +			(uint64_t)pci_map_single(oct->pci_dev,
> +						&droq->info_list[i],
> +						OCT_DROQ_INFO_SIZE,
> +						PCI_DMA_FROMDEVICE);
> +
> +		desc_ring[i].buffer_ptr =
> +			(uint64_t)pci_map_single(oct->pci_dev,
> +						droq->recv_buf_list[i].
> +						data, droq->buffer_size,
> +						PCI_DMA_FROMDEVICE);
> +	}

You should also check if pci mapping was successful...

Regards,
Lino
