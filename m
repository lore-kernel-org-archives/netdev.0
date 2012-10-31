From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/fib_trie: notify deleted routes on if down event
Date: Wed, 31 Oct 2012 12:36:24 -0400 (EDT)
Message-ID: <20121031.123624.1386289950274931267.davem@davemloft.net>
References: <1351611176-4000-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933109Ab2JaQg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 12:36:29 -0400
In-Reply-To: <1351611176-4000-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 30 Oct 2012 16:32:56 +0100

> This notification is missing in IPv4 (in IPv6, deleted routes are
> notified).
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

This is intentional, and your patch has been suggested before.

Routing daemons are expected to purge their tables of all routes for
an interface when the get the interface down event.
