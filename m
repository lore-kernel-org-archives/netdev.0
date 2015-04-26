From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7] Add support of Cavium Liquidio ethernet
 adapters
Date: Sun, 26 Apr 2015 16:04:07 -0400 (EDT)
Message-ID: <20150426.160407.2043024228389437605.davem@davemloft.net>
References: <1428540419.22406.70.camel@perches.com>
	<1429922056-14124-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbbDZUEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 16:04:46 -0400
In-Reply-To: <1429922056-14124-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Fri, 24 Apr 2015 17:34:16 -0700

> Following patch adds support for Cavium Liquidio ethernet adapter.
> LiquidIO adapters are pci express based 10Gig server adapters.
> 
> This patch v7 has changes based on the feedback from earlier patches:
> 
> 1) Minor comments from v6 release regarding debug statements.
> 2) Fix for large multicast lists.
> 3) Fixed lockup issue if port initialization fails.
> 4) Enabled MSI by default.
> 
> Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
> Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>

It is extremely disappointing that you've defined your own debug
logging macros, which use generic dev_*() printks, instead of using
the proper netdev_*() printk logging interfaces to do this.
