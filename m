From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: prevent WARN during driver unload
Date: Tue, 07 Jan 2014 15:45:46 -0500 (EST)
Message-ID: <20140107.154546.297973917685156649.davem@davemloft.net>
References: <1389089261-25714-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbaAGUps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:45:48 -0500
In-Reply-To: <1389089261-25714-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>
Date: Tue, 7 Jan 2014 12:07:41 +0200

> +	fp->state &= BNX2X_FP_STATE_DISABLED;
 ...
> +	fp->state &= BNX2X_FP_STATE_DISABLED;

Surely you mean "&= ~BNX2X_FP_STATE_DISABLED" here?
