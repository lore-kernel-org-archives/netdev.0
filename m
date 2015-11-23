From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/9] net: ipmr: cleanups and minor
 improvements
Date: Mon, 23 Nov 2015 15:07:06 -0500 (EST)
Message-ID: <20151123.150706.1526042817884567005.davem@davemloft.net>
References: <1448117852-4254-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbbKWUHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 15:07:08 -0500
In-Reply-To: <1448117852-4254-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Sat, 21 Nov 2015 15:57:23 +0100

> Since I'll have to work with ipmr, I decided to clean it up and do some
> minor improvements. Functionally there're almost no changes except the
> SLAB_PANIC removal. Most of the patches just re-design some functions to
> be clearer and more concise and try to remove the ifdef web that was
> inside. There's more information in each commit. This is the first set,
> the end goal is to introduce complete netlink support and control over
> the mfc and vif devices.
> I've tried to test all of the setsockopt/getsockopt options, and also
> made builds with various ipmr kconfig options turned on and off.
> 
> v2: change patch 7 to keep SLAB_PANIC and just drop the unnecessary null
> check

This series is pretty much fine, applied, thanks.
