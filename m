From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 0/5] simple gtp improvements
Date: Tue, 24 Jan 2017 18:23:57 +0100
Message-ID: <20170124172402.12096-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:37409 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750707AbdAXRYI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 12:24:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As requested are here the simple and most obvious changes from
the larger GTP changeset. I'll break down the rest and send them
out separately.

The module alias addition and the rcu_lock removal are just small
convenience changes.

The other changes are needed to correctly implement one of the
3GPP GW functions, userspace needs to see invalid T-PDU's in
order to generate the proper error messages, GTP fragmentation
rules need the cleared DF bit.

Andreas
