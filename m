From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3] SRR cleanups and kill rt_dst in ip_forward
Date: Thu, 12 May 2011 19:38:18 -0400 (EDT)
Message-ID: <20110512.193818.131302274961006326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757801Ab1ELXiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 19:38:24 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4CNcIAL007943
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 12 May 2011 16:38:23 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some minor cleanups to SRR option processing functions and then
kill the one use of rt->rt_dst in ip_forward().

Signed-off-by: David S. Miller <davem@davemloft.net>
