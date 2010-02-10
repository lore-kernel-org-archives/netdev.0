From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Wed, 10 Feb 2010 09:15:06 -0800
Message-ID: <20100210091506.4ea59c67@nehalam>
References: <201002100629.o1A6TFUk026363@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36329 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754109Ab0BJRPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 12:15:17 -0500
In-Reply-To: <201002100629.o1A6TFUk026363@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Feb 2010 22:29:15 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> +static struct pci_device_id bnad_pci_id_table[] = {
> +	{
> +	 .vendor = PCI_VENDOR_ID_BROCADE,
> +	 .device = PCI_DEVICE_ID_BROCADE_CATAPULT,
> +	 .subvendor = PCI_ANY_ID,
> +	 .subdevice = PCI_ANY_ID,
> +	 .class = PCI_CLASS_NETWORK_ETHERNET << 8,
> +	 .class_mask = 0xffff00},
> +	{0, 0}
> +};
> +
> +MODULE_DEVICE_TABLE(pci, bnad_pci_id_table

Use:

static DEFINE_PCI_DEVICE_TABLE(bnad_pci_id_table) = {
     
not sure if you require class/class_mask or can use
	PCI_VDEVICE(BROCADE, PCI_DEVICE_ID_BROCADE_CATAPLUT)

-- 
