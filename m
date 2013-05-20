From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 0/4] trivial clean up for e1000e driver
Date: Mon, 20 May 2013 16:15:03 +0800
Message-ID: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:54008 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278Ab3ETIPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 04:15:16 -0400
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 20 May 2013 18:12:46 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 510033578053
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:15:12 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4K80uB011927718
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:00:57 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4K8FAAB015519
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:15:11 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is several trivial clean up for e1000e driver.

Wei Yang (4):
  e1000e: Remove duplicate assignment of default rx/tx ring size
  e1000e: Use marco instead of digit for defining
    e1000_rx_desc_packet_split
  e1000e: Calculate the desc_len based on adapter type
  e1000e: Not initialize the e1000_ps_page array when packet-split is
    not used

 drivers/net/ethernet/intel/e1000e/e1000.h  |    3 --
 drivers/net/ethernet/intel/e1000e/hw.h     |    5 ++-
 drivers/net/ethernet/intel/e1000e/netdev.c |   47 +++++++++++++++-------------
 3 files changed, 29 insertions(+), 26 deletions(-)

-- 
1.7.5.4
