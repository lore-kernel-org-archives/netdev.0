From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 00/19] net_tx_t: network device transmit return value change
Date: Mon, 31 Aug 2009 22:50:39 -0700
Message-ID: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57430 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379AbZIAF6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a little change over a lot of files. It changes the
return value of network device transmit from an integer to
an enum type (like irqreturn_t).  This allows compiler to warn
about stupid code that tries to return -ENOBUFS or other mistakes
like that. All the code that did that is gone, but it would
be better to try and do some decent type checking.

This patch converts all the x86 drivers (except staging).
Other drivers will work but produce a warning until converted.

-- 

