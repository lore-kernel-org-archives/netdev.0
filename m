From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/5] More neigh simplifications.
Date: Sun, 17 Jul 2011 12:29:49 -0700 (PDT)
Message-ID: <20110717.122949.1167434585296050332.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797Ab1GQTaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 15:30:02 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6HJTxYr028498
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 12:30:01 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add helpers for duplicate copies of code.

Eliminate superfluous ops methods that always get set to
the same exact function.

Get rid of hh->hh_output method.

I guess the indirection removal is a non-trivial improvement because
these changes knock a full 2 seconds off of my udpflood tests. :-)

Signed-off-by: David S. Miller <davem@davemloft.net>
