From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix generic option settings
Date: Tue, 28 Jan 2014 18:09:22 -0800 (PST)
Message-ID: <20140128.180922.1243623470887031878.davem@davemloft.net>
References: <1390922931-2137-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: yanivr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbaA2CJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 21:09:23 -0500
In-Reply-To: <1390922931-2137-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>
Date: Tue, 28 Jan 2014 17:28:51 +0200

> When user tried to change generic options using "ethtool -s" command, while SFP
> module is plugged out or during module detection, the command would have failed
> with "Unsupported port type" message. The fix is to ignore the port option in 
> case it's same as the current port configuration.
> 
> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied, thanks.
