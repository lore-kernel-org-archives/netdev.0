From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] net,ipv4,ipv6: Correct assignment of
 skb->network_header to skb->tail
Date: Tue, 28 May 2013 22:44:33 -0700 (PDT)
Message-ID: <20130528.224433.533003178906165918.davem@davemloft.net>
References: <1369805268-6291-1-git-send-email-horms@verge.net.au>
	<1369805268-6291-8-git-send-email-horms@verge.net.au>
	<1369805751.5109.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759425Ab3E2Fod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 01:44:33 -0400
In-Reply-To: <1369805751.5109.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 May 2013 22:35:51 -0700

> Are you sure __u64 is needed on 32bit arches ?

It should be "unsigned long" or similar.
