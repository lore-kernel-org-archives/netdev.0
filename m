From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdev: set __percpu attribute on
 netdev_alloc_pcpu_stats
Date: Tue, 11 Mar 2014 16:37:46 -0400 (EDT)
Message-ID: <20140311.163746.552920260998285786.davem@davemloft.net>
References: <20140310094146.2aaa8e0e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755623AbaCKUht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 16:37:49 -0400
In-Reply-To: <20140310094146.2aaa8e0e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 10 Mar 2014 09:41:46 -0700

> This patch fixes sparse warnings in vlan driver.
> It propagates the sparse __percpu attribute from alloc_percpu
> into netdev_alloc_pcpu_stats. I expect it may trigger additional
> sparse warnings from other drivers that are missing the __percpu
> attribute.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
