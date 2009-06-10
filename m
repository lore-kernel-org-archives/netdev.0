From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [PATCH] mlx4_en: added pci_device_id table
Date: Wed, 10 Jun 2009 09:37:53 +0300
Message-ID: <4A2F54C1.2040507@mellanox.co.il>
References: <4A2E5B5B.7060701@mellanox.co.il> <adaws7k3dri.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Tziporet Koren <tziporet@mellanox.co.il>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:45489 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752638AbZFJFrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2009 01:47:10 -0400
In-Reply-To: <adaws7k3dri.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> Interesting approach...
> 
>  > +	{ PCI_VDEVICE(MELLANOX, 0x6340) }, /* MT25408 "Hermon" SDR */
>  > +	{ PCI_VDEVICE(MELLANOX, 0x634a) }, /* MT25408 "Hermon" DDR */
>  > +	{ PCI_VDEVICE(MELLANOX, 0x6354) }, /* MT25408 "Hermon" QDR */
>  > +	{ PCI_VDEVICE(MELLANOX, 0x6732) }, /* MT25408 "Hermon" DDR PCIe gen2 */
>  > +	{ PCI_VDEVICE(MELLANOX, 0x673c) }, /* MT25408 "Hermon" QDR PCIe gen2 */
> 
> does it make sense to load mlx4_en for these IB devices?
> 
>  - R.
> 
These are not "IB only" devices.
They are all "Multi protocol" devices and can function both as IB or Ethernet

Yevgeny
