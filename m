From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: sfq dump broken in 2.6.27-rc1
Date: Wed, 6 Aug 2008 18:02:37 -0700
Message-ID: <20080806180237.4912a677@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:42975 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512AbYHGBCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 21:02:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With only one sfq (on eth0), I am getting multiple results from
'tc qdisc ls'

# tc qdisc ls
qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 
qdisc sfq 8001: dev eth0 root limit 127p quantum 1514b 

Still bisecting, since there is no obvious reason for the sudden borkage.
