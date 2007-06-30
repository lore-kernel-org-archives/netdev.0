From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 10/21] r8169: merge with version 6.001.00 of Realtek's
 r8169 driver
Date: Sat, 30 Jun 2007 05:47:40 -0400
Message-ID: <468626BC.80805@pobox.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com> <20070629202510.GL3240@electric-eye.fr.zoreil.com> <1183149335.2642.10.camel@laptopd505.fenrus.org> <46857068.4050803@pobox.com> <20070630094138.GB13042@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34970 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754227AbXF3Jrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2007 05:47:46 -0400
In-Reply-To: <20070630094138.GB13042@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
>> Arjan van de Ven wrote:
>>>> +	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
>>> can you create a pci_set_latency_timer() for this please?
> [...]
>>>> +	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
>>>> +		pci_write_config_byte(tp->pci_dev, PCI_CACHE_LINE_SIZE, 
>>>> 0x08);
>>> and something for this as well?
>> Why?  Nothing here seems generic to me.
> 
> I.e. no need for pci_set_latency_timer(struct pci_dev *dev, u8 latency)
> neither pci_set_cache_line_size(struct pci_dev *dev, u8 size) ?

Yeah.  When it gets to be a one-line wrapper like that, I don't see much 
additional value in pci_set_cache_line_size() over 
pci_write_config_byte(,PCI_CACHE_LINE_SIZE,).

	Jeff


