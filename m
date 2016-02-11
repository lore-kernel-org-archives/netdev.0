From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/4] ipv6: add option to drop unicast encapsulated
 in L2 multicast
Date: Thu, 11 Feb 2016 04:28:03 -0500 (EST)
Message-ID: <20160211.042803.1404242456426060095.davem@davemloft.net>
References: <1454589080-21354-1-git-send-email-johannes@sipsolutions.net>
	<1454589080-21354-3-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org, ja@ssi.bg,
	johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbcBKJ2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 04:28:07 -0500
In-Reply-To: <1454589080-21354-3-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu,  4 Feb 2016 13:31:19 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> In order to solve a problem with 802.11, the so-called hole-196 attack,
> add an option (sysctl) called "drop_unicast_in_l2_multicast" which, if
> enabled, causes the stack to drop IPv6 unicast packets encapsulated in
> link-layer multi- or broadcast frames. Such frames can (as an attack)
> be created by any member of the same wireless network and transmitted
> as valid encrypted frames since the symmetric key for broadcast frames
> is shared between all stations.
> 
> Reviewed-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied.
