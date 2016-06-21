From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v3 0/5] bridge: json support for fdb and vlan show
Date: Mon, 20 Jun 2016 23:39:42 -0700
Message-ID: <1466491187-8536-1-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36253 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017AbcFUGjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 02:39:52 -0400
Received: by mail-pa0-f51.google.com with SMTP id wo6so3290377pac.3
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 23:39:51 -0700 (PDT)
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

v3 - no change. resubmitting as requested by stephen

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
