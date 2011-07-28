From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-next 0/2] vlan:remove duplicate <linux/if_vlan.h>
Date: Thu, 28 Jul 2011 16:37:38 +0800
Message-ID: <cover.1311841820.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:51926 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171Ab1G1IgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 04:36:22 -0400
Received: by mail-qw0-f46.google.com with SMTP id 3so1208684qwk.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 01:36:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As net/8021q/vlan.h already includes <linux/if_vlan.h>,
so other files that includes vlan.h need not to include it.

But before we remove it from net/8021q/vlan_gvrp.c,
we should first add add netdevice.h into stp.h.

[PATCH net-next 1/2]:add netdevice.h into stp.h
[PATCH net-next 2/2]:remove duplicate <linux/if_vlan.h>

Weiping Pan (2):
  stp:add netdevice.h into stp.h
  vlan:remove duplicate <linux/if_vlan.h>

 include/net/stp.h        |    2 ++
 net/8021q/vlan.c         |    1 -
 net/8021q/vlan_core.c    |    1 -
 net/8021q/vlan_dev.c     |    1 -
 net/8021q/vlan_gvrp.c    |    1 -
 net/8021q/vlan_netlink.c |    1 -
 net/8021q/vlanproc.c     |    1 -
 7 files changed, 2 insertions(+), 6 deletions(-)

-- 
1.7.4.4

