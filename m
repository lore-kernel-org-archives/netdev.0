From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: Add new tc classify variable
Date: Tue, 07 Feb 2012 13:58:41 -0500 (EST)
Message-ID: <20120207.135841.1753473725075272902.davem@davemloft.net>
References: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: simon.wunderlich@s2003.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35729 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992Ab2BGS6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 13:58:46 -0500
In-Reply-To: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
Date: Tue,  7 Feb 2012 19:39:08 +0100

> The linux traffic control mechanism has different ways to select the
> correct class of a qdisc. A common way to do this is to use tc filters
> that are directly attached to a qdisc. Another approach is to use the
> iptables classify module. The latter one can reduce the amount of work
> necessary to process a packet when iptables is already involved in the
> packet classification.

Do not bloat up sk_buff any more.  Add this, and the other existing
tc_* members to the qdisc SKB control block instead.
