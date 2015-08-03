From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Correct logic for pvid configuration.
Date: Sun, 02 Aug 2015 17:18:54 -0700 (PDT)
Message-ID: <20150802.171854.596690780702830379.davem@davemloft.net>
References: <1438508561-31209-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracel.com,
	Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbbHCAS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 20:18:57 -0400
In-Reply-To: <1438508561-31209-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sun, 2 Aug 2015 12:42:41 +0300

> Commit 05cc5a39ddb7 ("bnx2x: add vlan filtering offload") has introduced
> an incorrect logic for checking whether pvid should be configured for
> a vf, causing the hypervisor driver to send unneeded ramrods for all of
> the vfs each time a pvid has changed.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
> ---
> Looks like this has been hidden by the fact that
> VLAN_VALID == (1 << MAC_ADDR_VALID).
> Since MAC is almost always set by the hypervisor it simply caused
> additional ramrods to be sent instead of preventing the feature.

Applied, thank you.
