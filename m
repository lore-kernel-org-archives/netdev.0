From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH net-next v3 0/2] GTP SGSN-side tunnels
Date: Fri, 24 Mar 2017 10:33:56 +0100
Message-ID: <20170324093358.31374-1-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: pablo@netfilter.org, netdev@vger.kernel.org, laforge@gnumonks.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:49756 "EHLO mail.southpole.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751584AbdCXJex (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 05:34:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v2:

* Move #define of legacy netlink attribute into enum
* Added note to commit message about load-testing use-case
* Ack from Pablo

Jonas Bonn (2):
  gtp: rename SGSN netlink attribute
  gtp: support SGSN-side tunnels

 drivers/net/gtp.c            | 63 +++++++++++++++++++++++++++++---------------
 include/uapi/linux/gtp.h     |  3 ++-
 include/uapi/linux/if_link.h |  7 +++++
 3 files changed, 51 insertions(+), 22 deletions(-)

-- 
2.9.3
