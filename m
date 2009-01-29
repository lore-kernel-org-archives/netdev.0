From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/5] iptables lockless receive (v0.3)
Date: Wed, 28 Jan 2009 22:25:21 -0800
Message-ID: <20090129062521.092861272@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59978 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846AbZA2G1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 01:27:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another experimental version of iptables locking that removes
reader/writer lock overhead. This version incorprates suggestion
of moving counter to table_info.  I haven't done ebtables, and don't
know if it is worth bothering.

-- 

