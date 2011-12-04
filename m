From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/6] e1000e: Avoid wrong check on TX hang
Date: Sat, 03 Dec 2011 22:26:59 -0500 (EST)
Message-ID: <20111203.222659.277419094309941060.davem@davemloft.net>
References: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1322912671-6903-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangyun@linux.vnet.ibm.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, fbl@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32861 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020Ab1LDD1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 22:27:05 -0500
In-Reply-To: <1322912671-6903-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat,  3 Dec 2011 03:44:26 -0800

> +	if ((!adapter->tx_hang_recheck) &&

Excessive parenthesis, please remove.

> +		adapter->tx_hang_recheck = 1;

This variable is a bool, set it to true or false.

> +			adapter->tx_hang_recheck = 0;

Likewise.

> +	adapter->tx_hang_recheck = 0;

Likewise.
