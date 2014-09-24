From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/4] Fix up remaining defconfigs with missing CONFIG_NET
Date: Wed, 24 Sep 2014 14:49:08 -0400 (EDT)
Message-ID: <20140924.144908.34261036132770745.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454AbaIXStN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 14:49:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is on top of Michal Marek's series and the IA64 fixups which are
already in Linus's tree.

I validated things two different ways:

1) I scanned every arch config file, and if it mentioned CONFIG_INET or
   CONFIG_UNIX, I made sure it had CONFIG_NET=y

2) I scanned every arch config file, and if it did not have CONFIG_NET=y
   I made sure it did not reference any networking config options.

Signed-off-by: David S. Miller <davem@davemloft.net>
