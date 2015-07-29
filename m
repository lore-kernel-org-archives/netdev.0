From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bridge: stp: when using userspace stp stop
 kernel hello and hold timers
Date: Tue, 28 Jul 2015 23:33:33 -0700 (PDT)
Message-ID: <20150728.233333.793723681312359738.davem@davemloft.net>
References: <1437667657-16954-1-git-send-email-nikolay@cumulusnetworks.com>
	<1437674465-4388-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, razor@blackwall.org,
	sashok@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979AbbG2Gde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 02:33:34 -0400
In-Reply-To: <1437674465-4388-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 23 Jul 2015 11:01:05 -0700

> From: Nikolay Aleksandrov <razor@blackwall.org>
> 
> These should be handled only by the respective STP which is in control.
> They become problematic for devices with limited resources with many
> ports because the hold_timer is per port and fires each second and the
> hello timer fires each 2 seconds even though it's global. While in
> user-space STP mode these timers are completely unnecessary so it's better
> to keep them off.
> Also ensure that when the bridge is up these timers are started only when
> running with kernel STP.
> 
> Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
