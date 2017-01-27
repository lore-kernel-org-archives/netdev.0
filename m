From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net v3 0/3] various gtp fixes
Date: Fri, 27 Jan 2017 10:40:55 +0100
Message-ID: <20170127094058.7899-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>,
        SF Markus Elfring <elfring@users.sourceforge.net>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:41345 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932346AbdA0JlG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 04:41:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm sorry for the compile error mess up in the last version.
It's no excuse for not test compiling, but the hunks got lost in
a rebase.

This is the part of the previous "simple gtp improvements" series
that Pablo indicated should go into net.

The addition of the module alias fixes genl family autoloading,
clearing the DF bit fixes a protocol violation in regard to the
specification and the netns comparison fixes a corner case of
cross netns recv.

Andreas

v2->v3: fix compiler error introduced in rebase
