From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/8] bnx2x: ETS changes
Date: Sun, 27 Nov 2011 17:02:43 -0500 (EST)
Message-ID: <20111127.170243.558330614942737386.davem@davemloft.net>
References: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
	<1322417881-17760-3-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: yanivr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387Ab1K0WCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 17:02:46 -0500
In-Reply-To: <1322417881-17760-3-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yanivr@broadcom.com>
Date: Sun, 27 Nov 2011 20:17:55 +0200

> +			is_bw_cos_exist = 1;
> +			if (0 == ets_params->cos[cos_idx].params.bw_params.bw) {

These "0 == X" expressions are not what people commonly use
and therefore hard for others to read.  Either use
"X == 0" or "!X" which is much much more preferred.
