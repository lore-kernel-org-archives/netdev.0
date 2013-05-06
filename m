From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] S390: Fix libphy link failure
Date: Mon, 06 May 2013 12:00:56 -0400 (EDT)
Message-ID: <20130506.120056.594539889807741289.davem@davemloft.net>
References: <1367852019.4569.123.camel@chaos.site>
	<20130506.110011.1813294677998011362.davem@davemloft.net>
	<20130506154931.GA8453@osiris>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, netdev@vger.kernel.org, schwidefsky@de.ibm.com,
	gerald.schaefer@de.ibm.com, sebott@linux.vnet.ibm.com
To: heiko.carstens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab3EFQA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 12:00:59 -0400
In-Reply-To: <20130506154931.GA8453@osiris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Mon, 6 May 2013 17:49:31 +0200

> So you wouldn't mind some stupid stubs like
> 
> request_irq(unsigned int irq, irq_handler_t handler, unsigned long flags,
>             const char *name, void *dev) {
> 	    return -EWHATEVER;
> }
> 
> ?

It's your architecture, so I really don't care.

All I care is that we don't see S390 blobs any more in driver/net/
Kconfig's :-)
