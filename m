From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Sun, 01 Jul 2012 14:42:52 -0700 (PDT)
Message-ID: <20120701.144252.792146486861614931.davem@davemloft.net>
References: <1341135823-29039-7-git-send-email-ogerlitz@mellanox.com>
	<20120701.033055.489908836962064737.davem@davemloft.net>
	<4FF042B5.1000303@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, hadarh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427Ab2GAVnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 17:43:00 -0400
In-Reply-To: <4FF042B5.1000303@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 1 Jul 2012 15:29:41 +0300

> And for the time being use the module param, makes sense?

This talk about making an alternative, clean, mechanism later
is non-sense.  Because you'll never be able to get rid of this
module param once you add it.

Module parameters stink because every driver is going to provide the
knob differently, with a different name, and different semantics.

This creates a terrible user experience, and I will not allow it.
