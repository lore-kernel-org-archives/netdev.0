From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net] tg3: Fix crc errors on jumbo frame receive
Date: Mon, 14 Jan 2013 22:09:54 -0500 (EST)
Message-ID: <20130114.220954.2286778364579479114.davem@davemloft.net>
References: <1358219460-5993-1-git-send-email-mchan@broadcom.com>
	<1358219460-5993-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600Ab3AODJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 22:09:56 -0500
In-Reply-To: <1358219460-5993-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 14 Jan 2013 19:11:00 -0800

> From: Nithin Nayak Sujir <nsujir@broadcom.com>
> 
> TG3_PHY_AUXCTL_SMDSP_ENABLE/DISABLE macros do a blind write to the phy
> auxiliary control register and overwrite the EXT_PKT_LEN (bit 14) resulting
> in intermittent crc errors on jumbo frames with some link partners. Change
> the code to do a read/modify/write.
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
