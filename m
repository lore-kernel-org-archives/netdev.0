From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: Fix kernel crash on rmmod.
Date: Wed, 10 Jul 2013 17:52:33 -0700 (PDT)
Message-ID: <20130710.175233.571212108853436298.davem@davemloft.net>
References: <1373409548-26064-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256Ab3GKAwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 20:52:34 -0400
In-Reply-To: <1373409548-26064-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue,  9 Jul 2013 15:39:08 -0700

> Following commit fixes the crash by fixing module exit path.
 ...
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

This commit message is way too terse.

Please explain exactly why it's important to unregister the pernet
device after unregistering the rtnl link ops and destroying vxlan_wq.

Stephen explicitly put the operations in this order in commit
758c57d16adcbec3c03e85f0c9a5b4ca31f6c507 ("vxlan: fix crash from work
pending on module removal")
