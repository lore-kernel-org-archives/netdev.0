From: Octavian Purdila <opurdila@ixiacom.com>
Subject: TCP timewait recycle/reuse for IPv6?
Date: Mon, 17 Mar 2008 18:18:17 +0200
Message-ID: <200803171818.17494.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1118 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754549AbYCQQSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 12:18:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

Is there a way to prevent getting bind(in6addr_any) failures when we have lots 
of TIMEWAIT sockets hanging around? It looks like timewait reuse/recyle is 
not supported in the IPv6 stack. 


Thanks,
tavi
