From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 0/5] ADDRCONF/NDISC improvements
Date: Mon, 21 Jan 2013 02:38:31 +0900
Message-ID: <50FC2B97.7020601@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48869 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752371Ab3ATRid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 12:38:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are for address comparison improvements and boolean conversion.

YOSHIFUJI Hideaki (5):
  ipv6: Make ipv6_addr_is_XXX() return boolean.
  ipv6: Introduce ipv6_addr_is_solict_mult() to check Solicited Node
    Multicast Addresses.
  ipv6: Optimize ipv6_addr_is_solict_mult().
  ipv6: Optimize ipv6_addr_is_ll_all_{nodes,routers}().
  ndisc: Make several arguments for ndisc_send_na() boolean.

 include/net/addrconf.h |   33 +++++++++++++++++++++++++++++----
 net/ipv6/ndisc.c       |   16 ++++++----------
 2 files changed, 35 insertions(+), 14 deletions(-)

-- 
1.7.9.5
