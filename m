From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Fix FW flash logic using ethtool
Date: Tue, 14 Oct 2014 16:55:41 -0400 (EDT)
Message-ID: <20141014.165541.2051912226986471267.davem@davemloft.net>
References: <1413318254-23813-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com, anish@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbaJNUzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 16:55:45 -0400
In-Reply-To: <1413318254-23813-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 15 Oct 2014 01:54:14 +0530

> Use t4_fw_upgrade instead of t4_load_fw to write firmware into FLASH, since
> t4_load_fw doesn't co-ordinate with the firmware and the adapter can get hosed
> enough to require a power cycle of the system.
> 
> Based on original work by Casey Leedom <leedom@chelsio.com>
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
