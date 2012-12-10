From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 03/22] bnx2x: Add to VF <-> PF channel the
 release request
Date: Mon, 10 Dec 2012 13:39:09 -0500 (EST)
Message-ID: <20121210.133909.864954188870549983.davem@davemloft.net>
References: <1355154406-10855-1-git-send-email-ariele@broadcom.com>
	<1355154406-10855-4-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab2LJSjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 13:39:11 -0500
In-Reply-To: <1355154406-10855-4-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Mon, 10 Dec 2012 17:46:27 +0200

> +	/* PF released us */
> +	if (resp->hdr.status == PFVF_STATUS_SUCCESS) {
> +		DP(BNX2X_MSG_SP, "vf released\n");
> +
> +	/* PF reports error */
> +	} else {

Seriously?  Do I even need to tell you how awful this looks?

Remove the empty line and put that comment before the "else"
somewhere where it doesn't have to have indentation which does
not match the basic block it is in.

I think I've reviewed enough of this series, please audit the
rest of coding style problems yourself.
