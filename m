From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 10/21] r8169: merge with version 6.001.00 of Realtek's
 r8169 driver
Date: Fri, 29 Jun 2007 16:49:44 -0400
Message-ID: <46857068.4050803@pobox.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com> <20070629202510.GL3240@electric-eye.fr.zoreil.com> <1183149335.2642.10.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60069 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754257AbXF2Uts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:49:48 -0400
In-Reply-To: <1183149335.2642.10.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
>> +	pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
> 
> can you create a pci_set_latency_timer() for this please?
> 
>> +
>> +	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
>> +		pci_write_config_byte(tp->pci_dev, PCI_CACHE_LINE_SIZE, 0x08);
> 
> and something for this as well?

Why?  Nothing here seems generic to me.

	Jeff



