From: Amit Kumar Salecha <amit@netxen.com>
Subject: [net-2.6 PATCH 0/3] critical fixes
Date: Fri, 20 Nov 2009 17:09:31 -0800
Message-ID: <1258765774-27068-1-git-send-email-amit@netxen.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:27773 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752851AbZKUBJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 20:09:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi
   I am sending three patches, to fix some critical issues.

   1) Skip memory initialization during driver load. Device may not come up, if memory is reset.
   2) Fix promisc mode, kernel crashes with this bug. Drain rx queue before changing mode. 
   3) Fix bonding mode TLB/ALB, correct mac address need to communicate to device.

-Amit Salecha
