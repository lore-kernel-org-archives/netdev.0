From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/14] qed: Add CONFIG_QED_SRIOV
Date: Mon, 09 May 2016 15:14:29 -0400 (EDT)
Message-ID: <20160509.151429.403288621356878412.davem@davemloft.net>
References: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1462799963-23547-2-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbcEITOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 15:14:31 -0400
In-Reply-To: <1462799963-23547-2-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 9 May 2016 16:19:10 +0300

> +	/* bitmap indicating which fields hold valid values */
> +	aligned_u64 valid_bitmap;

There is absolutely no reason to use aligned_u64 here.  That type is for
handling a specific issue in user facing APIs, which this is not.
