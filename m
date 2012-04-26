From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ehea: fix promiscuous mode
Date: Thu, 26 Apr 2012 05:08:18 -0400 (EDT)
Message-ID: <20120426.050818.1152356410786660098.davem@davemloft.net>
References: <1335375132-4591-1-git-send-email-cascardo@linux.vnet.ibm.com>
	<1335375132-4591-2-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leitao@linux.vnet.ibm.com
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755512Ab2DZJIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:08:23 -0400
In-Reply-To: <1335375132-4591-2-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Wed, 25 Apr 2012 14:32:12 -0300

> commit a4910b744486254cfa61995954c118fb2283c4fd has broken promiscuous
> mode, which is never set. port->promisc just reflects the last setting
> of PROMISCUOUS mode to avoid doing an extra hypercall when it's already
> set.
> 
> However, since it may fail because of hypervisor permissions, we should
> still respect the multicast settings and not simply exit after setting
> promiscuous mode.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> Cc: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied.
