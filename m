From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/18] Kill off NLMSG_NEW and NLMSG_PUT
Date: Tue, 26 Jun 2012 22:01:55 -0700 (PDT)
Message-ID: <20120626.220155.1298849942906073647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab2F0FB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:01:59 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 153C0584190
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Bad API, embedded gotos, error prone, etc.

Next pass we'll have to deal with the RTA_PUT*() macros
too.

Signed-off-by: David S. Miller <davem@davemloft.net>
