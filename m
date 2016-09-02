From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 0/2] vxlan: fix error reporting
Date: Fri,  2 Sep 2016 13:37:10 +0200
Message-ID: <cover.1472815982.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44740 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751836AbcIBLh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 07:37:28 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3BCE18123B
        for <netdev@vger.kernel.org>; Fri,  2 Sep 2016 11:37:23 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-85.brq.redhat.com [10.40.204.85])
        by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u82BbMAj001359
        for <netdev@vger.kernel.org>; Fri, 2 Sep 2016 07:37:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset improves checking for invalid configuration in VXLAN and fixes
problems with duplicated and inappropriate error messages.

Jiri Benc (2):
  vxlan: reject multicast destination without an interface
  vxlan: fix duplicated and wrong error messages

 drivers/net/vxlan.c | 38 ++++++++++++--------------------------
 1 file changed, 12 insertions(+), 26 deletions(-)

-- 
1.8.3.1
