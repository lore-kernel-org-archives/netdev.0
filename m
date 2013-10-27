From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 0/2] bnx2x: Bug fixes patch series
Date: Sun, 27 Oct 2013 13:06:59 +0200
Message-ID: <1382872021-1116-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, ariele@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1499 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751881Ab3J0LHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 07:07:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains 2 unrelated fixes:

 1. FW asserts during unload might be encountered if specific memory
    allocations fail during load.

 2. SR-IOV related, fixes a crash that will occour if the driver were to
    be rmmoded and then re-probed while there are both assigned and unassigned
    VFs originating from the same PF.

Please consider applying these patches to `net'.

Thanks,
Yuval Mintz
