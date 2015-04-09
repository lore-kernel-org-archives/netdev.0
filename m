From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v6] Add support of Cavium Liquidio ethernet
 adapters
Date: Wed, 08 Apr 2015 17:46:59 -0700
Message-ID: <1428540419.22406.70.camel@perches.com>
References: <CO2PR07MB490581C7747937513D93972FE2D0@CO2PR07MB490.namprd07.prod.outlook.com>
	 <1428520101-9197-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0050.hostedemail.com ([216.40.44.50]:44314 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754696AbbDIArD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 20:47:03 -0400
In-Reply-To: <1428520101-9197-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-08 at 12:08 -0700, Raghu Vatsavayi wrote:
> Following patch adds support for Cavium Liquidio ethernet adapter.
> LiquidIO adapters are pci express based 10Gig server adapters.

Hi.  One tiny bit of trivia:

You might want to add terminating '\n' to these
format lines one day:

+	lio_dev_dbg(oct, "droq[%d]: desc_ring: virt: 0x%p, dma: %lx",
+		    q_no, droq->desc_ring, droq->desc_ring_dma);
+	lio_dev_dbg(oct, "droq[%d]: num_desc: %d", q_no, droq->max_count);
