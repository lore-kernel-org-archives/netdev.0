From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Sun, 01 Jul 2012 03:23:33 -0700 (PDT)
Message-ID: <20120701.032333.1556514531569655610.davem@davemloft.net>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	<1341135823-29039-10-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, hadarh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755242Ab2GAKXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 06:23:34 -0400
In-Reply-To: <1341135823-29039-10-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  1 Jul 2012 12:43:42 +0300

> +		en_err(priv, "Fail to detach network rule at location %d. registration id = 0x%llx\n"
> +		       , cmd->fs.location, rule->id);

Put that first comma at the end of the first line, this is very ugly.
