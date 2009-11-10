From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 00/10] netdev: get rid of read_lock(&dev_base_lock) usages
Date: Tue, 10 Nov 2009 09:54:46 -0800
Message-ID: <20091110175446.280423729@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58701 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753786AbZKJSG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:06:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal is to eliminate dev_base_lock completely, and just use RCU
and rtnl_mutex for network devices. This series gets rid of the many
of the users of dev_base_lock just for reading.

-- 

