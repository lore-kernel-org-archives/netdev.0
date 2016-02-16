From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] ethtool: correct {GS}CHANNELS and {GS}RXFH
 conflict
Date: Tue, 16 Feb 2016 15:20:15 -0500 (EST)
Message-ID: <20160216.152015.2100460835710785492.davem@davemloft.net>
References: <1454976306-23523-1-git-send-email-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, moorray3@wp.pl
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755474AbcBPUUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:20:18 -0500
In-Reply-To: <1454976306-23523-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>
Date: Mon,  8 Feb 2016 16:05:02 -0800

> This patch series fixes up ethtool_set_channels operation which
> allowed modifying the RXFH table indirectly by reducing the number of
> queues below the current max queue used by the Rx flow table. Most
> drivers incorrectly allowed this to destroy the Rx flow table and
> would then start by reinitializing it to default settings. However,
> drivers are not able to correctly handle the conflict since there was
> no way to differentiate between the default settings and the user
> requested explicit settings.
 ...

Patches 1-3 applied to net-next, thanks.
