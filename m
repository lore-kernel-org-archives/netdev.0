From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fix icmpv6 endian bug and other sparse warnings
Date: Thu, 13 Dec 2012 13:02:06 -0500 (EST)
Message-ID: <20121213.130206.625082915523751967.davem@davemloft.net>
References: <50c926ab.AI4jRk2MW3J/QuQj%fengguang.wu@intel.com>
	<20121213085128.1db11ee4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, amwang@redhat.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755904Ab2LMSCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 13:02:08 -0500
In-Reply-To: <20121213085128.1db11ee4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 13 Dec 2012 08:51:28 -0800

> Fix the warnings reported by sparse on recent bridge multicast
> changes. Mostly just rcu annotation issues but in this case
> sparse found a real bug! The ICMPv6 mld2 query mrc
> values is in network byte order.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
