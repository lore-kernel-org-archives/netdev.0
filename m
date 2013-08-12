From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net v5 0/5] bnx2x: fixes
Date: Tue, 13 Aug 2013 02:24:58 +0300
Message-ID: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1210 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755596Ab3HLXZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Aug 2013 19:25:16 -0400
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
v4->v5
	* patch 2/6: replace proprietary locking with semaphore
	* droped 1/6: since adds redundant code from Benjamin Poirier

Thanks
Dmitry 
