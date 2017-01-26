From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v2 0/2] gtp: simple gtp improvements
Date: Thu, 26 Jan 2017 16:21:47 +0100
Message-ID: <20170126152149.3284-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>,
        SF Markus Elfring <elfring@users.sourceforge.net>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:52362 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752825AbdAZPV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 10:21:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the part of the previous "simple gtp improvements" series
that Pablo indicated should go into net-next.

The rcu_lock removal is small correctness changes. Passing invalid
to user space allows for more standards compliant handling of invalid
tunnels.
