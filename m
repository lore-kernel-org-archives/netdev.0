From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] be2net: patch set
Date: Thu, 17 Jul 2014 16:38:39 -0700 (PDT)
Message-ID: <20140717.163839.1715643021000195231.davem@davemloft.net>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758044AbaGQXik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 19:38:40 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Thu, 17 Jul 2014 16:20:18 +0530

> Patches 1 to 6 address issues with return values of some ndo/ethtool
> driver methods. In error scenarios, either an inappropriate error or
> a +ve return value (where the stack expects a -ve value) was being returned.
> 
> Patch 7 updates description strings for certain UE bits.
> 
> Patch 8 cleans up (reduces) argument passing for a few routines in be_cmds.c.
> 
> Patch 9 removes some unused code (unused definitions.)
> 
> Patch 10 updates NULL check in the driver to a consistent "if (!foo)" style.
> 
> Patchs 11 to 13 fix a few minor issues with the earlier patch bec84e6
> ("create optimal number of queues on SR-IOV config"):
> 	- patch 11 fixes BEx_get_resources() code to use be_max_vfs() macro
> 	- patch 12 skips SR-IOV config code for BE2 that doesn't support SRIOV
> 	- patch 13 uses adapter->flags to track SRIOV enabled state
> 
> Patch 14 updates the driver version.
> 
> Please consider applying to the net-next tree. Thanks.

Series applied, thanks.
