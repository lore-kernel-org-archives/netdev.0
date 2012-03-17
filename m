From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] bonding: send igmp report for its master
Date: Fri, 16 Mar 2012 22:58:19 -0700 (PDT)
Message-ID: <20120316.225819.536895807414721517.davem@davemloft.net>
References: <f5d199e12d78dadcfb932e103984276d36b186e0.1331539261.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143Ab2CQF6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 01:58:24 -0400
In-Reply-To: <f5d199e12d78dadcfb932e103984276d36b186e0.1331539261.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>
Date: Wed, 14 Mar 2012 11:37:22 +0800

> +	if (unlikely(master_dev)) {
> +		__bond_resend_igmp_join_requests(master_dev);
> +	}

Please do not enclose a single-statement basic block inside of
braces.
