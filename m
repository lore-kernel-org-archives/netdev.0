From: Octavian Purdila <opurdila@ixiacom.com>
Subject: TCP_SKB_CB(skb)->flags = iph->tos ?
Date: Fri, 30 May 2008 23:53:56 +0300
Message-ID: <200805302353.56440.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:2728 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751244AbYE3UzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 16:55:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tcp_v4_rcv says: TCP_SKB_CB(skb)->flags = iph->tos;

I am probably missing something obvious, but shouldn't flags be initialized 
with the TCP headers instead of the IP TOS value?

Thanks,
tavi
