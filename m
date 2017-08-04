From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/1] netvsc: fix deadlock in VF unregister
Date: Fri,  4 Aug 2017 12:13:59 -0700
Message-ID: <20170804191400.22471-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33432 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbdHDTOE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 15:14:04 -0400
Received: by mail-pg0-f53.google.com with SMTP id u5so11404340pgn.0
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 12:14:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a race in VF unregister (in net-next only) which can be triggered
if SR-IOV is disabled on host side, which causes PCI hotplug removal.

Stephen Hemminger (1):
  netvsc: fix rtnl deadlock on unregister of vf

 drivers/net/hyperv/netvsc_drv.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

-- 
2.11.0
