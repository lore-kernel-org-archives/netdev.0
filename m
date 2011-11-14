From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net, bridge: print log message after state changed
Date: Mon, 14 Nov 2011 00:37:02 -0500 (EST)
Message-ID: <20111114.003702.1097206603722725705.davem@davemloft.net>
References: <1320941934-3534-1-git-send-email-holger.brunck@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wolfgang.fritz@keymile.com,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org
To: holger.brunck@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab1KNFhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 00:37:10 -0500
In-Reply-To: <1320941934-3534-1-git-send-email-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Brunck <holger.brunck@keymile.com>
Date: Thu, 10 Nov 2011 17:18:54 +0100

> From: Wolfgang Fritz <wolfgang.fritz@keymile.com>
> 
> Function br_log_state writes log message "... entering XXXX state" so it
> should be called after the state has changed and not before.
> 
> Signed-off-by: Wolfgang Fritz <wolfgang.fritz@keymile.com>
> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>

"entering" can roughly mean "about to enter"

The message is therefore appropriately timed as far as I'm concerned.

I'm not applying this patch.
