From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/5] cxgb4 : Add DCBx support codebase and
 dcbnl_ops
Date: Thu, 19 Jun 2014 21:15:46 -0700 (PDT)
Message-ID: <20140619.211546.719163351289410442.davem@davemloft.net>
References: <1403216531-7874-1-git-send-email-anish@chelsio.com>
	<1403216531-7874-3-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, hariprasad@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbaFTEPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 00:15:49 -0400
In-Reply-To: <1403216531-7874-3-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Thu, 19 Jun 2014 15:22:08 -0700

> +#ifdef CONFIG_CHELSIO_T4_DCB
> +	struct port_dcb_info dcb;     /* Data Center Bridging support */
> +#endif

Don't reference data structure which do not exist until patches
later in your series.  Add those definitions first.

Your submission is impossible to review, and in fact presents itself
illogically, when you introduce infrastructure after it's uses.
