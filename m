From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnxt_en: Remove locking around txr->dev_state
Date: Tue, 19 Jul 2016 19:22:54 -0700 (PDT)
Message-ID: <20160719.192254.1399232158462742537.davem@davemloft.net>
References: <1468626125-31732-1-git-send-email-f.fainelli@gmail.com>
	<1468872171-10009-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
	huangjw@broadcom.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752398AbcGTCW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 22:22:57 -0400
In-Reply-To: <1468872171-10009-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 18 Jul 2016 13:02:47 -0700

> txr->dev_state was not consistently manipulated with the acquisition of
> the per-queue lock, after further inspection the lock does not seem
> necessary, either the value is read as BNXT_DEV_STATE_CLOSING or 0.
> 
> Reported-by: coverity (CID 1339583)
> Fixes: c0c050c58d840 ("bnxt_en: New Broadcom ethernet driver.")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
> 
> - remove locking in bnxt_tx_disable() as recommended by Michael

Applied to net-next, thanks.
