From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 0/3] e1000e: protect NVM from corruption
Date: Tue, 23 Sep 2008 15:25:37 -0700
Message-ID: <20080923222320.6075.90496.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com
To: jeff@garzik.org, mingo@elte.hu, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:50009 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbYIWWZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 18:25:32 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2382258rvb.1
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 15:25:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches apply against commit e002bcc2f8e766a96472379e3b4a8a4e8938a93e of Linus's latest tree.

These patches have had some basic tested run against them.  These patches are intended to prevent the NVM corruption being reported and will hopefully help in finding a root cause for the NVM corruption.

---

Bruce Allan (3):
      e1000e: remove failed request for sw/fw/hw flag
      e1000e: Useset_memory_ro()/set_memory_rw() to protect flash memory
      x86: export set_memory_ro() and set_memory_rw() calls


 arch/x86/mm/pageattr.c       |    2 ++
 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/hw.h      |    1 +
 drivers/net/e1000e/ich8lan.c |   18 ++++++++++++++++++
 drivers/net/e1000e/netdev.c  |   11 +++++++----
 5 files changed, 29 insertions(+), 4 deletions(-)

-- 
Signature
