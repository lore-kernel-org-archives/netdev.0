From: David Miller <davem@davemloft.net>
Subject: Re: [RFC Patch net-next] ipv6: look up neighbours on demand in
 ip6_finish_output2()
Date: Mon, 14 Jan 2013 13:30:04 -0500 (EST)
Message-ID: <20130114.133004.19237632940616685.davem@davemloft.net>
References: <1358170515-1383-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@purestorage.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756010Ab3ANSaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 13:30:09 -0500
In-Reply-To: <1358170515-1383-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a very incomplete patch.

If this change were so simple, it would have been done by someone
else a long time ago.

You must, in addition to the incredibly obvious changes in the packet
output path, completely eliminate the caching of the neighbour entry
in the ipv6 routes themselves.

This means replacing every rt6->n access or test with something
equivalent.
