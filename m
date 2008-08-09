From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 7/7] e1000e: remove unnecessary snippet missed in prior
	check_options update
Date: Fri, 08 Aug 2008 18:36:16 -0700
Message-ID: <20080809013616.23913.20271.stgit@localhost.localdomain>
References: <20080809013544.23913.47157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2924 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756544AbYHIBgS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 21:36:18 -0400
In-Reply-To: <20080809013544.23913.47157.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The removal of this bit of code was missed in an earlier patch submittal.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/param.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index b0499f2..ed912e0 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -324,8 +324,6 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 				adapter->itr = 20000;
 				break;
 			default:
-				e1000_validate_option(&adapter->itr, &opt,
-					adapter);
 				/*
 				 * Save the setting, because the dynamic bits
 				 * change itr.

