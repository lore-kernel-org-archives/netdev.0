From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net v2 0/3] various gtp fixes
Date: Thu, 26 Jan 2017 16:11:31 +0100
Message-ID: <20170126151134.2892-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:49545 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752681AbdAZPLl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 10:11:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the part of the previous "simple gtp improvements" series
that Pablo indicated should go into net.

The addition of the module alias fixes genl family autoloading,
clearing the DF bit fixes a protocol violation in regard to the
specification and the netns comparison fixes a corner case of
cross netns recv.

I'm not sure if Pablos comments on the previous version qualify
as ACK, so I left that out.
