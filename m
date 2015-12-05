From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Revert "i40e: remove CONFIG_I40E_VXLAN"
Date: Sat, 05 Dec 2015 17:50:19 -0500 (EST)
Message-ID: <20151205.175019.927737740812545846.davem@davemloft.net>
References: <1449215371-18357-1-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: anjali.singhai@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbbLEWuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 17:50:20 -0500
In-Reply-To: <1449215371-18357-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>
Date: Thu,  3 Dec 2015 23:49:31 -0800

> This reverts commit 8fe269991aece394a7ed274f525d96c73f94109a.
> The case where VXLAN is a module and i40e driver is inbuilt
> will not be handled properly with this change since i40e
> will have an undefined symbol vxlan_get_rx_port in it.
> 
> v2: Add a signed-off-by.
> 
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>

Why isn't this going via Jeff Kirsher?  And why isn't he even
CC:'d?
