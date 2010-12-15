From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 00/12 net-next] cxgb4 update v2
Date: Tue, 14 Dec 2010 23:36:43 -0800
Message-ID: <1292398615-26527-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16965 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222Ab0LOHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:45:19 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBF7jICE004129
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:45:18 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBF7atIS026573
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:36:55 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBF7atO9026572
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 23:36:55 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is v2 of the cxgb4 series.  I've removed the fallback call to kcalloc in
patch 12 per Eric's comment and restored an accidentally removed increment in
patch 7.

 drivers/net/cxgb4/cxgb4.h      |    4 +-
 drivers/net/cxgb4/cxgb4_main.c |  134 +++++++++++++++++++---------------------
 drivers/net/cxgb4/sge.c        |   22 +++++--
 drivers/net/cxgb4/t4_hw.c      |   93 ++++++++++++++--------------
 drivers/net/cxgb4/t4fw_api.h   |    1 +
 5 files changed, 127 insertions(+), 127 deletions(-)
