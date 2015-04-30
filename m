From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bnx2x: Alloc 4k fragment for each rx ring buffer
 element
Date: Thu, 30 Apr 2015 16:05:37 -0400 (EDT)
Message-ID: <20150430.160537.232956261880122754.davem@davemloft.net>
References: <553AD097.4020209@gmx.de>
	<87383jhxj9.fsf@dhcp-9-18-235-171.br.ibm.com>
	<B5657A6538887040AD3A81F1008BEC63D383CB@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krisman@linux.vnet.ibm.com, LinoSanfilippo@gmx.de,
	Ariel.Elior@qlogic.com, netdev@vger.kernel.org,
	cascardo@linux.vnet.ibm.com, cascardo@cascardo.eti.br,
	brking@linux.vnet.ibm.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680AbbD3UFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 16:05:41 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63D383CB@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 30 Apr 2015 11:25:31 +0000

>> +struct bnx2x_alloc_pool {
>> +	struct page	*page;
>> +	dma_addr_t	dma;
>> +	int		len;
> 
> Isn't len always set to PAGE_SIZE? If so it can be dropped

Agreed, len appears unnecessary.
