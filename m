From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/3] Convert packet and key sockets to RCU
Date: Fri, 19 Feb 2010 13:59:13 -0800
Message-ID: <20100219215913.819285957@vyatta.com>
Cc: netdev@vger.kernel.org
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Peter Oberparleiter <oberpar@linux.vnet.ibm.com>,
	Miklos S
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49102 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753470Ab0BSWGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2010 17:06:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set converts AF_PACKET and AF_KEY socket familys to
use RCU rather than reader/writer lock.
-- 

