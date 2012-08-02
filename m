From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] net/mlx4: Fixes to mlx4 driver
Date: Thu, 02 Aug 2012 16:12:51 -0700 (PDT)
Message-ID: <20120802.161251.331601378090436432.davem@davemloft.net>
References: <1343921456-19180-1-git-send-email-yevgenyp@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613Ab2HBXMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 19:12:55 -0400
In-Reply-To: <1343921456-19180-1-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu,  2 Aug 2012 18:30:52 +0300

> Yevgeny Petrilin (3):
>   net/mlx4_en: Setting the NETIF_F_GRO flag back to dev->hw_features

As pointed out, this isn't a bug.

You just made this change purely via code inspection, and that's very
disappointing because this would have been so simple to validate.
