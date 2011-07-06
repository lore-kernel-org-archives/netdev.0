From: David Miller <davem@davemloft.net>
Subject: [PATCH v3 0/4] Packet fanout support
Date: Tue, 05 Jul 2011 20:39:50 -0700 (PDT)
Message-ID: <20110705.203950.572162456454922371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: victor@inliniac.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968Ab1GFDjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 23:39:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the final revision of this patch set and what I'm
going to push out to net-next-2.6

The only changes this round are two bug fixes to patch #2:

1) fanout_add() oops fix

2) __fanout_unlink() was going

	spin_unlock
	..
	spin_unlock

   instead of

	spin_unlock
	..
	spin_unlock
