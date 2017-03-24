From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH net-next v5 0/2] GTP SGSN-side tunnel
Date: Fri, 24 Mar 2017 23:23:19 +0100
Message-ID: <20170324222321.28618-1-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: pablo@netfilter.org, netdev@vger.kernel.org, laforge@gnumonks.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:52225 "EHLO mail.southpole.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934956AbdCXWX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 18:23:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v4:

* Respin the series on top of net-next; the conflicts were trivial,
  amounting to just code having been shifted about

Jonas Bonn (2):
  gtp: rename SGSN netlink attribute
  gtp: support SGSN-side tunnels

 drivers/net/gtp.c            | 64 ++++++++++++++++++++++++++++----------------
 include/uapi/linux/gtp.h     |  3 ++-
 include/uapi/linux/if_link.h |  7 +++++
 3 files changed, 50 insertions(+), 24 deletions(-)

-- 
2.9.3
