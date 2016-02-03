From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] bridge: mdb: flag offloaded mdb entries
Date: Wed,  3 Feb 2016 09:57:03 +0100
Message-ID: <1454489826-1858-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37240 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755112AbcBCI5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 03:57:09 -0500
Received: by mail-wm0-f47.google.com with SMTP id l66so59445768wml.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 00:57:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset extends uapi to let the user know if an mdb entry is offloaded.

Elad Raz (3):
  bridge: mdb: add support for offloaded mdb entries
  bridge: mdb: Separate br_mdb_entry->state from
    net_bridge_port_group->state
  bridge: mdb: Passing the port-group pointer to br_mdb module

 include/uapi/linux/if_bridge.h |  2 ++
 net/bridge/br_mdb.c            | 63 ++++++++++++++++++++++++++----------------
 net/bridge/br_multicast.c      | 18 ++++++------
 net/bridge/br_private.h        | 11 +++++---
 4 files changed, 56 insertions(+), 38 deletions(-)

-- 
1.9.3
