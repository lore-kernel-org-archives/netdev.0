From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: Add support for adaptive interrupt
 coalescing
Date: Wed, 07 May 2014 17:00:43 -0400 (EDT)
Message-ID: <20140507.170043.896249393177676627.davem@davemloft.net>
References: <1399386262-20769-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com,
	neepatel@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbaEGVAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 17:00:45 -0400
In-Reply-To: <1399386262-20769-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Tue,  6 May 2014 19:54:22 +0530

> From: Sujith Sankar <ssujith@cisco.com>
> 
> Signed-off-by: Sujith Sankar <ssujith@cisco.com>
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Please never submit patches except absolutely the most extremely
trivial ones without a real commit log message explaining what
the change does, how it does it, and why you implemented it that
way.

> +enum hrtimer_restart enic_hrtimer_cb(struct hrtimer *timer)
> +{
> +	return HRTIMER_RESTART;
> +}

For example, I have no idea why in the world you need an hrtimer whose
function is a complete NOP if the networking hardware does the
interrupt coalescing for you.
