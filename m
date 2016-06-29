From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bridge: fix vlan stats continue counter
Date: Wed, 29 Jun 2016 05:40:01 -0400 (EDT)
Message-ID: <20160629.054001.1335885793021861692.davem@davemloft.net>
References: <1467045282-21612-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbcF2Jkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 05:40:31 -0400
In-Reply-To: <1467045282-21612-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Mon, 27 Jun 2016 18:34:42 +0200

> I made a dumb off-by-one mistake when I added the vlan stats counter
> dumping code. The increment should happen before the check, not after
> otherwise we miss one entry when we continue dumping.
> 
> Fixes: a60c090361ea ("bridge: netlink: export per-vlan stats")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
