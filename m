From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 00/12 net-next] cxgb4 update
Date: Tue, 14 Dec 2010 12:18:04 -0800
Message-ID: <1292357896-14339-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22554 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759759Ab0LNU0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 15:26:39 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBEKQcR6031245
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:26:38 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBEKIGJ3014431
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:18:16 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBEKIGuv014430
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 12:18:16 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here's a set of 12 patches for cxgb4.  About half are clean ups, the rest
either small non-critical fixes or enhancements.  All for net-next.

 drivers/net/cxgb4/cxgb4.h      |    4 +-
 drivers/net/cxgb4/cxgb4_main.c |  130 +++++++++++++++++++---------------------
 drivers/net/cxgb4/sge.c        |   25 ++++++--
 drivers/net/cxgb4/t4_hw.c      |   93 ++++++++++++++--------------
 drivers/net/cxgb4/t4fw_api.h   |    1 +
 5 files changed, 128 insertions(+), 125 deletions(-)
