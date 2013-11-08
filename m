From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 0/2] ixgbe: macvlan fixes
Date: Fri, 08 Nov 2013 00:50:07 -0800
Message-ID: <20131108084654.6935.36501.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:35823 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662Ab3KHIuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 03:50:25 -0500
Received: by mail-ob0-f173.google.com with SMTP id wm4so1242344obc.4
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 00:50:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two additional fixes for ixgbe l2 forwarding acceleration. One
was reported by kbuild build bot and the second after hardening
my test scripts.

Typically I would send ixgbe fixes through JeffK's tree but I
know a few people who are looking at the feature in their setup's 
so wanted to be sure the patches were visible.

For reference the ixgbe accelerated macvlan patch is here:

commit 2a47fa45d4dfbc54659d28de311a1f764b296a3c
Author: John Fastabend <john.r.fastabend@intel.com>
Date:   Wed Nov 6 09:54:52 2013 -0800

    ixgbe: enable l2 forwarding acceleration for macvlans

Thanks,
John

---

John Fastabend (2):
      ixgbe: fix build err, num_rx_queues is only available with CONFIG_RPS
      ixgbe: deleting dfwd stations out of order can cause null ptr deref


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

-- 
Signature
