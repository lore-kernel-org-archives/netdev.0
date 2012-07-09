From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch v2] bnx2x: Add run-time CNIC support
Date: Mon, 09 Jul 2012 14:10:10 -0700 (PDT)
Message-ID: <20120709.141010.996787793429264956.davem@davemloft.net>
References: <1341828055-4467-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, dmitry@broadcom.com
To: meravs@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab2GIVKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 17:10:11 -0400
In-Reply-To: <1341828055-4467-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Merav Sicron" <meravs@broadcom.com>
Date: Mon, 9 Jul 2012 13:00:55 +0300

> -	max_non_def_sbs = bnx2x_get_num_non_def_sbs(pdev);
> +	cnic_enabled = IS_ENABLED(CONFIG_CNIC) ? 1 : 0;

This, as I said, it pointless.

Every distribution is going to turn on this Kconfig option so guarding
this at all using the Kconfig option is largely valueless.
