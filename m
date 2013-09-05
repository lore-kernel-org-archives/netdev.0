From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] icplus: Use netif_running to determine device state
Date: Thu, 05 Sep 2013 14:27:52 -0400 (EDT)
Message-ID: <20130905.142752.890397668917511619.davem@davemloft.net>
References: <1378319161-18850-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, sorbica@icplus.com.tw
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855Ab3IES1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 14:27:54 -0400
In-Reply-To: <1378319161-18850-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Wed,  4 Sep 2013 11:26:01 -0700

> Remove the __LINK_STATE_START check to verify the device is running, in
> favor of netif_running().  netif_running() performs the same check of
> __LINK_STATE_START, so the code should behave the same.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Applied, thanks.
