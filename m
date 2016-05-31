From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v2 0/5] bridge: json support for fdb and vlan show
Date: Mon, 30 May 2016 19:17:11 -0700
Message-ID: <1464661036-35532-1-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34817 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162295AbcEaCRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 22:17:20 -0400
Received: by mail-pf0-f182.google.com with SMTP id g64so69387166pfb.2
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 19:17:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch series adds json support for a few bridge show commands.
We plan to follow up with json support for additional commands soon.

Anuradha Karuppiah (3):
  json_writer: allow base json data type to be array or object
  bridge: add json support for bridge fdb show
  bridge: add json schema for bridge fdb show

Roopa Prabhu (2):
  bridge: add json support for bridge vlan show
  bridge: update man page

v2 - change vlan flags to an array as suggested by toshiaki

 bridge/br_common.h            |   1 +
 bridge/bridge.c               |   3 +
 bridge/fdb.c                  | 201 +++++++++++++++++++++++++++++++++---------
 bridge/vlan.c                 |  93 ++++++++++++++++++-
 include/json_writer.h         |   5 +-
 lib/json_writer.c             |  39 +++++++-
 man/man8/bridge.8             |   9 +-
 misc/ifstat.c                 |   6 +-
 misc/lnstat.c                 |   2 +-
 misc/nstat.c                  |   4 +-
 schema/bridge_fdb_schema.json |  62 +++++++++++++
 11 files changed, 365 insertions(+), 60 deletions(-)
 create mode 100644 schema/bridge_fdb_schema.json

-- 
1.9.1
