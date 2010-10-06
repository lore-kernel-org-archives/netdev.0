From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 00/19] bnx2x, cnic, bnx2i: Supporting 57712
 device
Date: Wed, 6 Oct 2010 15:13:33 +0200
Message-ID: <1286370813.30552.7.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755497Ab0JFNjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:39:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series is aimed to add support for the 57712 device. To support it,
the drivers needs to adopts the new FW interfaces and therefore the support for
the 57710 and 57711 changed as well (together with new FW for those devices).
Mostly it replaces the FW with new one that supports new HW, but also it moves
firmware files to bnx2x folder and includes some minor changes discovered
during FW/HW integration.

The new device has VF and FCoE capabilities - those are not enabled in this
patch series.

Since the FW files are too big and will not pass through the mailing list, it is
also located at:
http://linux.broadcom.com/eilong/1.60.00-1

01 cnic: Pass cp pointer to BNX2X_HW_CID.
02 cnic: Use pfid for internal memory offsets.
03 cnic: Fine-tune ring init code.
04 bnx2x: create folder for bnx2x firmware files
05 bnx2x: add 6.0.34 fw files
06 bnx2x, cnic, bnx2i: use new FW/HSI
07 bnx2x: remove old FW files 
08 bnx2x: rename MF related fields
09 bnx2x: change type of spq_left to atomic
10 bnx2x: Add 57712 support
11 bnx2x: remove unused parameter in reuse_rx_skb()
12 bnx2x: remove unused fields in main driver structure
13 bnx2x: use proper constants for dma_unmap* calls
14 bnx2x: use L1_CACHE_BYTES instead of magic number
15 bnx2x: move msix table initialization to probe()
16 bnx2x, cnic: Fix SPQ return credit
17 bnx2x: code beautify
18 bnx2x: properly initialize FW stats
19 bnx2x: update version to 1.60.00-1

Please consider applying to net-next.

Thanks,
Dmitry



