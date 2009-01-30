From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/6] iptables: eliminate read/write lock (v0.4)
Date: Fri, 30 Jan 2009 13:57:00 -0800
Message-ID: <20090130215700.965611970@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49648 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753967AbZA3V5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 16:57:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More of Eric's suggestions, handle the case of aggregation of
counters correctly.  Unfortunately, can't easily make xt_add_counter
inline because DEFINE_PER_CPU doesn't seem to export to modules correctly.

-- 

