From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 0/4] s390: ctcm / lcs / claw fixes for 2.6.27
Date: Thu, 21 Aug 2008 17:10:21 +0200
Message-ID: <20080821151021.069615000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:55805 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758045AbYHUPRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 11:17:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Hi Jeff,

Here are some drivers/s390/net fixes for 2.6.27:

- removal of claw memory leak
- make use of ml_priv field of struct net_device in claw driver
- make use of ml_priv field of struct net_device in ctcm driver
- recovery fix for lcs driver

Thanks, Ursula Braun
