From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Early TCP socket demux
Date: Thu, 26 Jul 2012 14:29:03 -0700 (PDT)
Message-ID: <20120726.142903.2061753292000961457.davem@davemloft.net>
References: <1343298868.2626.11348.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032Ab2GZV3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 17:29:04 -0400
In-Reply-To: <1343298868.2626.11348.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Jul 2012 12:34:28 +0200

> +	if (sysctl_ip_early_demux && !skb_dst(skb)) {

You obviously don't build ipv6 modular.

sysctl_ip_early_demux needs to be exported to modules in order
for this to work.
