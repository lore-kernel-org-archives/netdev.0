From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 0/2] vxlan: do not error out on disabled IPv6
Date: Thu, 27 Apr 2017 21:24:34 +0200
Message-ID: <cover.1493320999.git.jbenc@redhat.com>
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33480 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034806AbdD0T1f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 15:27:35 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 250328E3F0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 19:27:34 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes a bug with metadata based tunnels when booted with
ipv6.disable=1.


Jiri Benc (2):
  vxlan: correctly handle ipv6.disable module parameter
  vxlan: do not output confusing error message

 drivers/net/vxlan.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

-- 
1.8.3.1
