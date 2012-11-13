From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/22] bnx2x: Support probing and removing of VF device
Date: Tue, 13 Nov 2012 14:22:13 -0500 (EST)
Message-ID: <20121113.142213.2194625760657823261.davem@davemloft.net>
References: <1352823451-27042-1-git-send-email-ariele@broadcom.com>
	<1352823451-27042-2-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab2KMTWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 14:22:14 -0500
In-Reply-To: <1352823451-27042-2-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Tue, 13 Nov 2012 18:17:10 +0200

> @@ -1579,6 +1598,7 @@ struct bnx2x {
>  	char			fw_ver[32];
>  	const struct firmware	*firmware;
>  
> +
>  	/* DCB support on/off */
>  	u16 dcb_state;
>  #define BNX2X_DCB_STATE_OFF			0

Please re-review this entire patch series and get rid of
gratuitous things like the unnecessary empty line being
added here.

Thanks.
