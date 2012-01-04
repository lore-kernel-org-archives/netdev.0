From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Check RA for sllao when configuring optimistic
 ipv6 address
Date: Wed, 04 Jan 2012 14:43:18 -0500 (EST)
Message-ID: <20120104.144318.1141715284599085189.davem@davemloft.net>
References: <1325695643-27656-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798Ab2ADTpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 14:45:38 -0500
In-Reply-To: <1325695643-27656-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed,  4 Jan 2012 11:47:23 -0500

> +extern void addrconf_prefix_rcv(struct net_device *dev,
> +				u8 *opt, int len, void *sllao);

You're not going to dereference or inspect 'sllao' otherwise you'd
give it a more appropriate type.  You just care if it was present or
not.

So why not just make 'sllao' a "bool" and the argument passed as the
test "X != NULL"?
