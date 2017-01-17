From: Igor Druzhinin <igor.druzhinin@citrix.com>
Subject: [PATCH v2 0/2] xen-netback: fix memory leaks on XenBus disconnect
Date: Tue, 17 Jan 2017 20:49:36 +0000
Message-ID: <1484686178-76959-1-git-send-email-igor.druzhinin@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Paul.Durrant@citrix.com>, <xen-devel@lists.xenproject.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Igor Druzhinin <igor.druzhinin@citrix.com>
To: <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just split the initial patch in two as proposed by Wei.

Since the approach for locking netdev statistics is inconsistent (tends not
to have any locking at all) accross the kernel we'd better to rely on our
internal lock for this purpose.

Igor Druzhinin (2):
  xen-netback: fix memory leaks on XenBus disconnect
  xen-netback: protect resource cleaning on XenBus disconnect

 drivers/net/xen-netback/interface.c |  6 ++++--
 drivers/net/xen-netback/xenbus.c    | 13 +++++++++++++
 2 files changed, 17 insertions(+), 2 deletions(-)

-- 
1.8.3.1
