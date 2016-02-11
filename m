From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/4] ipv4: add option to drop gratuitous ARP packets
Date: Thu, 11 Feb 2016 04:27:56 -0500 (EST)
Message-ID: <20160211.042756.1789940987586580734.davem@davemloft.net>
References: <1454589080-21354-1-git-send-email-johannes@sipsolutions.net>
	<1454589080-21354-2-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org, ja@ssi.bg,
	johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbcBKJ17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 04:27:59 -0500
In-Reply-To: <1454589080-21354-2-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu,  4 Feb 2016 13:31:18 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> In certain 802.11 wireless deployments, there will be ARP proxies
> that use knowledge of the network to correctly answer requests.
> To prevent gratuitous ARP frames on the shared medium from being
> a problem, on such deployments wireless needs to drop them.
> 
> Enable this by providing an option called "drop_gratuitous_arp".
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied.
