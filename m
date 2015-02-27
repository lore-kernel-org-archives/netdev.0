From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 2/4] ipv4: Use binary search to choose tcp
 PMTU probe_size
Date: Fri, 27 Feb 2015 17:17:05 -0500 (EST)
Message-ID: <20150227.171705.858493469862589196.davem@davemloft.net>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>
	<1424922566-6787-1-git-send-email-fan.du@intel.com>
	<1424922566-6787-3-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, fengyuleidian0615@gmail.com
To: fan.du@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754962AbbB0WRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:17:08 -0500
In-Reply-To: <1424922566-6787-3-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@intel.com>
Date: Thu, 26 Feb 2015 11:49:24 +0800

> Current probe_size is chosen by doubling mss_cache,
> the initial mss base is 512 Bytes, as a result the
> converged probe_size will only be 1024 Bytes, there
> is still big gap between 1024 and common 1500 bytes
> of mtu.

After patch #1 in this series it is not longer 512.

You need to update this commit message to match reality.
