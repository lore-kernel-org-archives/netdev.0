From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 0/4] cxgb4 updates
Date: Mon, 23 Aug 2010 20:20:57 -0700
Message-ID: <1282620061-32608-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27166 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab0HXD2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:28:21 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o7O3SLM6022367
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 20:28:21 -0700
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o7O3L1c4032651
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 20:21:01 -0700
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o7O3L1L1032650
	for netdev@vger.kernel.org; Mon, 23 Aug 2010 20:21:01 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are 4 patches for cxgb4 enabling the driver to work on PCI functions
other than 0.  The first 3 are preparatory, the last one updates PCI IDs.
All for net-next.

 drivers/net/cxgb4/cxgb4.h      |    2 +
 drivers/net/cxgb4/cxgb4_main.c |   94 +++++++++++++++++++++++++++++----------
 drivers/net/cxgb4/sge.c        |   17 ++++---
 drivers/net/cxgb4/t4_hw.h      |    1 +
 drivers/net/cxgb4/t4fw_api.h   |    5 ++
 5 files changed, 88 insertions(+), 31 deletions(-)
