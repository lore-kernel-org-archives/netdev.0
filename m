From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 0/2] net: rename device's sysfs symlinks on name change
Date: Tue, 14 Jan 2014 21:58:49 +0100
Message-ID: <1389733131-15390-1-git-send-email-vfalico@redhat.com>
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56073 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534AbaANVDS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 16:03:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch only adds helper functions and cleans up the code a bit, second
one already does the renaming.

v1->v2:
Don't export the function, as it's used only in dev.c.

Reported-by: Ding Tianhong <dingtianhong@huawei.com>
CC: Ding Tianhong <dingtianhong@huawei.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
CC: Cong Wang <amwang@redhat.com>
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 include/linux/netdevice.h |  1 +
 net/core/dev.c            | 80 +++++++++++++++++++++++++++++++----------------
 2 files changed, 54 insertions(+), 27 deletions(-)
