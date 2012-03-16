From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Replace IS_ENABLED(CONFIG_FCOE) in linux/netdevice.h
Date: Thu, 15 Mar 2012 20:51:39 -0400 (EDT)
Message-ID: <20120315.205139.858349725408037483.davem@davemloft.net>
References: <1331857815-2333-1-git-send-email-tony@bakeyournoodle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.w.love@intel.com, JBottomley@parallels.com,
	devel@open-fcoe.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
To: tony@bakeyournoodle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750Ab2CPAx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 20:53:58 -0400
In-Reply-To: <1331857815-2333-1-git-send-email-tony@bakeyournoodle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Breeds <tony@bakeyournoodle.com>
Date: Fri, 16 Mar 2012 11:30:15 +1100

> On platforms that (or configs that do not have PCI support building any
> code that includes linux/netdevice.h we see the following warnings:
> 
> include/linux/netdevice.h:964:1: warning: "__enabled_CONFIG_FCOE" is not defined [-Wundef]
> include/linux/netdevice.h:964:1: warning: "__enabled_CONFIG_FCOE_MODULE" is not defined [-Wundef]
> 
> In the case of this file we can trivially fallback to the old school
>  #if defined(...) syntax.
> 
> Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>

Fix IS_ENABLED to handle cases like this so we don't need special
cases like this scattered around the tree.
