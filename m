From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/5] Inetpeer roots in FIB tables
Date: Mon, 11 Jun 2012 02:28:57 -0700 (PDT)
Message-ID: <20120611.022857.2179255842843212895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab2FKJ3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 05:29:06 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 2D21E584265
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 02:29:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch series should fix the problem in the bugzilla Stephen
forwarded last week, in that we won't cache metrics properly for
source based routes.

Committed to net-next.

Signed-off-by: David S. Miller <davem@davemloft.net>
