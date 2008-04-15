From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH v2.6.26 0/2] Dynamic TBIPA for gianfar
Date: Tue, 15 Apr 2008 12:49:20 -0400
Message-ID: <1208278162-17462-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62506 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853AbYDOQua (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 12:50:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These patches allow boards with a PHY at the end of the bus to function,
by having the TBIPA set dynamically.  The 1st patch factors out some of
the PHY probe code so it can be recycled by the TBIPA probe, and the
second patch implements the dynamic probe itself.

Paul.
