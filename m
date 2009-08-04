From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: [0/6] vxge: a few bug fixes and performance tweaks for vxge
Date: Tue, 4 Aug 2009 16:20:13 -0400
Message-ID: <20090804202013.GA9924@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33061 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932502AbZHDUj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:39:57 -0400
Received: from guinness.s2io.com (localhost [127.0.0.1])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id C8DA42066019
	for <netdev@vger.kernel.org>; Tue,  4 Aug 2009 16:20:17 -0400 (EDT)
Received: from guinness.s2io.com (142-46-210.147.tel-ott.com [142.46.210.147]) by barracuda.s2io.com with ESMTP id I8HwhjIn6BARDu8o for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 16:20:17 -0400 (EDT)
Received: from neterion.com ([10.16.18.36])
	by guinness.s2io.com (8.12.6/8.12.6) with ESMTP id n74KKEmd013236
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 16:20:15 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

This patch series consists of several bug fixes and performance enhancements 
for the vxge driver.  They have passed internal QA.  Please apply.

	[1/6] vxge: don't drop frame on tx queue full
	[2/6] vxge: fix pktgen hangs (don't abuse skb->cb[])
	[3/6] vxge: improve tx performance by using mmiowb() instead of wmb()
	[4/6] vxge: prefetch RxD descriptors
	[5/6] vxge: prefetch skb->data
	[6/6] vxge: Version update

Signed-off-by: Benjamin LaHaise <ben.lahaise@neterion.com>
---
 vxge-config.h  |    7 ++++--
 vxge-main.c    |   66 ++++++++++++++++++++++++++++++++++-----------------------
 vxge-main.h    |    4 ++-
 vxge-traffic.c |   12 ++++++----
 vxge-traffic.h |    2 -
 vxge-version.h |    4 +--
 6 files changed, 58 insertions(+), 37 deletions(-)
