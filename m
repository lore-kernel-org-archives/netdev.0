From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFT 0/4] Iptables rwlock elimination
Date: Tue, 27 Jan 2009 15:53:10 -0800
Message-ID: <20090127235310.159946902@vyatta.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:40008 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038AbZA0X5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 18:57:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are some experimental patches to eliminate the read/write lock
in the fast path of iptables.  Not a big iptables user myself, so these
more review and testing.

-- 

