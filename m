From: Octavian Purdila <opurdila@ixiacom.com>
Subject: question regarding (AF_INET6, SOCK_RAW, IPPROTO_RAW) sockets
Date: Wed, 12 Mar 2008 18:34:29 +0200
Message-ID: <200803121834.29293.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3526 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751029AbYCLQuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 12:50:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I've noticed that when using IPv6 raw sockets with IPPROTO_RAW protocol and 
IPV6_PKTINFO set, we are not allow to specify a source address that it is not 
configured in the system. 

Disabling ipv6_chk_addr in datagram_send_ctl for IPv6 raw sockets seems to fix 
our problem. Is this approach the right one?

Thanks,
tavi
