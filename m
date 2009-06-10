From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] mlx4_en: added pci_device_id table
Date: Tue, 09 Jun 2009 21:37:37 -0700
Message-ID: <adaws7k3dri.fsf@cisco.com>
References: <4A2E5B5B.7060701@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Tziporet Koren <tziporet@mellanox.co.il>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:51757 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbZFJEhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 00:37:35 -0400
In-Reply-To: <4A2E5B5B.7060701@mellanox.co.il> (Yevgeny Petrilin's message of
	"Tue, 09 Jun 2009 15:53:47 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interesting approach...

 > +	{ PCI_VDEVICE(MELLANOX, 0x6340) }, /* MT25408 "Hermon" SDR */
 > +	{ PCI_VDEVICE(MELLANOX, 0x634a) }, /* MT25408 "Hermon" DDR */
 > +	{ PCI_VDEVICE(MELLANOX, 0x6354) }, /* MT25408 "Hermon" QDR */
 > +	{ PCI_VDEVICE(MELLANOX, 0x6732) }, /* MT25408 "Hermon" DDR PCIe gen2 */
 > +	{ PCI_VDEVICE(MELLANOX, 0x673c) }, /* MT25408 "Hermon" QDR PCIe gen2 */

does it make sense to load mlx4_en for these IB devices?

 - R.
