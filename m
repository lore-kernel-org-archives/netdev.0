From: Dan Streetman <dan.streetman@canonical.com>
Subject: [PATCH stable] Set a large MTU on ovs-created tunnel devices
Date: Fri, 3 Jun 2016 13:49:09 -0400
Message-ID: <CAOZ2QJNufB+4ffEpaab6iWotM_4+PQKVcEorEN9Hckh3NiJaQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:34367 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517AbcFCRtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 13:49:49 -0400
Received: by mail-yw0-f181.google.com with SMTP id c127so87164887ywb.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 10:49:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can you queue up these commits for stable?

commit 72564b59ffc438ea103b0727a921aaddce766728
Author: David Wragg <david@weave.works>
Date:   Wed Feb 10 00:05:55 2016 +0000

    vxlan: Relax MTU constraints


commit 55e5bfb53cff286c1c1ff49f51325dc15c7fea63
Author: David Wragg <david@weave.works>
Date:   Wed Feb 10 00:05:57 2016 +0000

    geneve: Relax MTU constraints


commit 7e059158d57b79159eaf1f504825d19866ef2c42
Author: David Wragg <david@weave.works>
Date:   Wed Feb 10 00:05:58 2016 +0000

    vxlan, gre, geneve: Set a large MTU on ovs-created tunnel devices
