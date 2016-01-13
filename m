From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 0/2] 3c59x: Fix dma map/unmap imbalances
Date: Wed, 13 Jan 2016 12:43:52 -0500
Message-ID: <1452707034-16379-1-git-send-email-nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33254 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755380AbcAMRoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 12:44:14 -0500
Received: from hmsreliant.think-freely.org ([2001:470:8:a08:7aac:c0ff:fec2:933b] helo=localhost)
	by smtp.tuxdriver.com with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.63)
	(envelope-from <nhorman@tuxdriver.com>)
	id 1aJPSr-0002KW-Lq
	for netdev@vger.kernel.org; Wed, 13 Jan 2016 12:44:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	recent enhancements to libdma revealed a few minor bugs in 3c59x, in
which dma ranges were mapped as singles and unmaped as pages, or vice versa.
These patches fix those up.  Tested by myself with success

Best
Neil
