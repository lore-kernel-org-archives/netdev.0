From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: release lock after each bucket in
 vxlan_cleanup
Date: Wed, 27 May 2015 13:33:54 -0400 (EDT)
Message-ID: <20150527.133354.6138980662036861.davem@davemloft.net>
References: <1432626124-24676-1-git-send-email-sorin@returnze.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sdumitru@ixiacom.com
To: sorin@returnze.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbbE0Rd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:33:56 -0400
In-Reply-To: <1432626124-24676-1-git-send-email-sorin@returnze.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sorin Dumitru <sorin@returnze.ro>
Date: Tue, 26 May 2015 10:42:04 +0300

> We're seeing some softlockups from this function when there
> are a lot fdb entries on a vxlan device. Taking the lock for
> each bucket instead of the whole table is enough to fix that.
> 
> Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>

Applied, thanks.
