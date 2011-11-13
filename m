From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3 net-next 09/12] bnx2x: add fan failure event handling
Date: Sun, 13 Nov 2011 13:11:57 -0800
Message-ID: <1321218717.15834.11.camel@Joe-Laptop>
References: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
	 <1321194872-8276-10-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41889 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751592Ab1KMVL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 16:11:59 -0500
In-Reply-To: <1321194872-8276-10-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-11-13 at 16:34 +0200, Dmitry Kravkov wrote:
> From: Ariel Elior <ariele@broadcom.com>
> Shut down the device in case of fan failure to prevent HW damage.
trivia.
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
[]
> @@ -8503,6 +8514,17 @@ sp_rtnl_not_reset:
[]
> +	if (test_and_clear_bit(BNX2X_SP_RTNL_FAN_FAILURE, &bp->sp_rtnl_state)) {
> +		DP(BNX2X_MSG_SP, "fan failure detected. Unloading driver");

Missing a trailing "\n".
