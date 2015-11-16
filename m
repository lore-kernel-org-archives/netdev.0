From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] snmp: Remove duplicate OUTMCAST stat increment
Date: Mon, 16 Nov 2015 16:37:05 -0500 (EST)
Message-ID: <20151116.163705.812151279432749334.davem@davemloft.net>
References: <1447697350-28652-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claus.jensen@microsemi.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181AbbKPVhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 16:37:07 -0500
In-Reply-To: <1447697350-28652-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 16 Nov 2015 13:09:10 -0500

> the OUTMCAST stat is double incremented, getting bumped once in the mcast code
> itself, and again in the common ip output path.  Remove the mcast bump, as its
> not needed
> 
> Validated by the reporter, with good results
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Claus Jensen <claus.jensen@microsemi.com>

Applied and queued up for -stable, thanks Neil.
