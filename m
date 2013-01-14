From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 0/6] IPv6: 64bit functions.
Date: Tue, 15 Jan 2013 02:09:41 +0900
Message-ID: <50F43BD5.3090002@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39829 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756663Ab3ANRJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 12:09:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of changes is about low-level address/prefix
manipulation functions, which basically introduces 64bit
variants of them.

YOSHIFUJI Hideaki (6):
  ipv6: 64bit version of ipv6_addr_diff().
  ipv6: 64bit version of ipv6_addr_loopback().
  ipv6: 64bit version of ipv6_addr_v4mapped().
  ipv6: 64bit version of ipv6_addr_set().
  ipv6: Remove __ipv6_prefix_equal().
  ipv6: 64bit version of ipv6_prefix_equal().

 include/net/ipv6.h |  111 ++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 94 insertions(+), 17 deletions(-)

-- 
1.7.9.5
