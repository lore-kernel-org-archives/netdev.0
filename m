From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/7] Deconstruct struct fib_result
Date: Fri, 27 Jul 2012 21:18:14 -0700 (PDT)
Message-ID: <20120727.211814.1628871775065221675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab2G1ESP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 00:18:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set tries to move towards reducing struct fib_result down
to it's absolute minimum.

The eventual idea is to make it so that fib_lookup() simply
returns a "struct fib_nh *" and pointer encoded errnos, instead
of writing into a complicated structure as the return value on
the stack as is done now.

Signed-off-by: David S. Miller <davem@davemloft.net>
