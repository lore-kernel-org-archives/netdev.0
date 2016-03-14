From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] r8169:Remove unnecessary phy reset for pcie nic
 when setting link spped.
Date: Sun, 13 Mar 2016 22:33:06 -0400 (EDT)
Message-ID: <20160313.223306.1073610379327320464.davem@davemloft.net>
References: <1457677274-2248-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbcCNCdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 22:33:09 -0400
In-Reply-To: <1457677274-2248-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chunhao Lin <hau@realtek.com>
Date: Fri, 11 Mar 2016 14:21:14 +0800

> For pcie nic, after setting link speed and there is no link driver does not need
> to do phy reset until link up.
> 
> For some pcie nics, to do this will also reset phy speed down counter and prevent
> phy from auto speed down.
> 
> This patch fix the issue reported in following link.
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1547151
> 
> Signed-off-by: Chunhao Lin <hau@realtek.com>

Applied, thanks.
