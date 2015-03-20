From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix backtracking for throw routes
Date: Fri, 20 Mar 2015 13:19:57 -0400 (EDT)
Message-ID: <20150320.131957.1183757074506860115.davem@davemloft.net>
References: <1426778164-4286-1-git-send-email-cyrus@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cyrus@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbbCTRT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 13:19:59 -0400
In-Reply-To: <1426778164-4286-1-git-send-email-cyrus@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Barth <cyrus@openwrt.org>
Date: Thu, 19 Mar 2015 16:16:04 +0100

> for throw routes to trigger evaluation of other policy rules
> EAGAIN needs to be propagated up to fib_rules_lookup
> similar to how its done for IPv4
> 
> A simple testcase for verification is:
> 
> ip -6 rule add lookup 33333 priority 33333
> ip -6 route add throw 2001:db8::1
> ip -6 route add 2001:db8::1 via fe80::1 dev wlan0 table 33333
> ip route get 2001:db8::1
> 
> Signed-off-by: Steven Barth <cyrus@openwrt.org>

Applied and queued up for -stable.
