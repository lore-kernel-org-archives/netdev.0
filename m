From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 0/1]qlcnic: fix set mac addr
Date: Wed,  7 Apr 2010 04:01:53 -0700
Message-ID: <1270638114-15323-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:27962 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752102Ab0DGLB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Apr 2010 07:01:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
  Sending 1 important patch to fix bonding enviornment.
  Mac addresses are not correctly communicated/set to fw, hence fw drops
  packets as mac address doesn't match.

  This fix need to be included in net-2.6 branch.

-Amit
