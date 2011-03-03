From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [BUG] VPN broken in net-next
Date: Wed, 2 Mar 2011 16:28:26 -0800
Message-ID: <20110302162826.59f52c77@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54923 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab1CCA22 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 19:28:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My PPTP VPN is broken with net-next tree, it works fine with 2.6.38-rc6
but not in the next tree. Bisected the problem down to the following commit.

Debugging to see which address request is failing with the new code.

9435eb1cf0b76b323019cebf8d16762a50a12a19 is the first bad commit
commit 9435eb1cf0b76b323019cebf8d16762a50a12a19
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Feb 18 12:43:09 2011 -0800

    ipv4: Implement __ip_dev_find using new interface address hash.
    
    Much quicker than going through the FIB tables.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 265fa1882ee3430f74d59c9b38b6aca0858396d6 28a01a4941f99f7c266fd84f36cc27b933d426c1 M	net
