From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net v4 0/6] bnx2x: fixes
Date: Tue, 6 Aug 2013 00:35:38 +0300
Message-ID: <1375738544-8695-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1137 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754585Ab3HEVgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 17:36:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave

Please consider applying the series of bnx2x fixes to net:
	* statistics may cause FW assert
	* missing fairness configuration in DCB flow
	* memory leak in sriov related part
	* Illegal PTE access
	* Pagefault crash in shutdown flow with cnic
v1->v2
	* fixed sparse error pointed by Joe Perches
	* added missing signed-off from Sergei Shtylyov
v2->v3
	* added missing signed-off from Sergei Shtylyov
	* fixed formatting from Sergei Shtylyov
v3->v4
	* patch 1/6: fixed declaration order
	* patch 2/6 replaced with: protect flows using set_bit constraints

Thanks
Dmitry 
