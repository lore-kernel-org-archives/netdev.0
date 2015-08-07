From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] gro: Fixes for tunnels and GRO
Date: Thu, 06 Aug 2015 18:55:26 -0700 (PDT)
Message-ID: <20150806.185526.64377836907678412.davem@davemloft.net>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbbHGBz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 21:55:27 -0400
In-Reply-To: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 3 Aug 2015 10:11:14 -0700

> This patch set addresses some issue related to tunneling and GRO:

As others have mentioned, the SIT GRO support was explicitly reverted
because it is broken and there were bug reports against it.

Until those are resolved you cannot put the GRO methods back into
the SIT driver.

THanks.
