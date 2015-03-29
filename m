From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] be2net: patch set
Date: Sun, 29 Mar 2015 12:34:26 -0700 (PDT)
Message-ID: <20150329.123426.338748218073465203.davem@davemloft.net>
References: <1427353510-24790-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbbC2TZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 15:25:43 -0400
In-Reply-To: <1427353510-24790-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Thu, 26 Mar 2015 03:05:07 -0400

> Hi David, this patch set includes 2 feature additions to the be2net driver:
> 
> Patch 1 sets up cpu affinity hints for be2net irqs using the
> cpumask_set_cpu_local_first() API that first picks the near numa cores
> and when they are exhausted, selects the far numa cores.
> 
> Patch 2 setups up xps queue mapping for be2net's TXQs to avoid,
> by default, TX lock contention.
> 
> Patch 3 just bumps up the driver version.
> 
> Pls consider applying this patch set to the net-next queue. Thanks!

Series applied, thanks.
