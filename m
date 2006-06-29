From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 0/9] pcnet32: NAPI support
Date: Thu, 29 Jun 2006 13:51:43 -0700
Message-ID: <20060629205143.GA21982@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:26252 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751278AbWF2Uv3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 16:51:29 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5TKpSvf000554
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:51:28 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5TKpjIS189216
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 14:51:45 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5TKpRRl006315
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 14:51:28 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches to the pcnet32 driver implement NAPI and fix some other
errors found during NAPI development and testing.  Please apply to
2.6.18.

1/9 Fix Section mismatch error
2/9 Use PCI_DEVICE macro
3/9 Fix off-by-one in get_ringparam
4/9 Use kcalloc instead of kmalloc and memset
5/9 Handle memory allocation failures cleanly when resizing tx/rx rings
6/9 Suspend the chip rather than restart when changing multicast/promisc
7/9 Cleanup rx buffers after loopback test.
8/9 NAPI implementation.
9/9 Magic number cleanup.
-- 
Don Fry
brazilnut@us.ibm.com
