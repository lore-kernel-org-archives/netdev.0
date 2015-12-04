From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "i40e: remove CONFIG_I40E_VXLAN"
Date: Thu, 03 Dec 2015 20:36:24 -0500 (EST)
Message-ID: <20151203.203624.965876308312409032.davem@davemloft.net>
References: <1449186399-229337-1-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: anjali.singhai@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167AbbLDBg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 20:36:28 -0500
In-Reply-To: <1449186399-229337-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>
Date: Thu,  3 Dec 2015 15:46:39 -0800

> This reverts commit 8fe269991aece394a7ed274f525d96c73f94109a.
> The case where VXLAN is a module and i40e driver is in built
> will not be handled properly with this change since i40e
> will have an undefined symbol vxlan_get_rx_port in it.

All commits, even straight reverts, must have a proper signoff.
