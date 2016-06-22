From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v4 0/5] bridge: json support for fdb and vlan show
Date: Wed, 22 Jun 2016 06:45:50 -0700
Message-ID: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34090 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbcFVNqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 09:46:00 -0400
Received: by mail-pa0-f41.google.com with SMTP id bz2so17168440pad.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 06:46:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch series adds json support for a few bridge show commands.
We plan to follow up with json support for additional commands soon.

Anuradha Karuppiah (3):
  json_writer: Removed automatic json-object type from the constructor
  bridge: add json support for bridge fdb show
  bridge: add json schema for bridge fdb show

Roopa Prabhu (2):
  bridge: add json support for bridge vlan show
  bridge: update man page

v2 - change vlan flags to an array as suggested by toshiaki

v3 - no change. resubmitting as requested by stephen

v4 - removed json type from constructor as recommended by stephen

 bridge/br_common.h            |   1 +
 bridge/bridge.c               |   5 +-
 bridge/fdb.c                  | 210 +++++++++++++++++++++++++++++++++---------
 bridge/vlan.c                 | 109 +++++++++++++++++++---
 lib/json_writer.c             |   6 +-
 man/man8/bridge.8             |   9 +-
 misc/ifstat.c                 |   7 ++
 misc/nstat.c                  |   6 ++
 schema/bridge_fdb_schema.json |  62 +++++++++++++
 9 files changed, 352 insertions(+), 63 deletions(-)
 create mode 100644 schema/bridge_fdb_schema.json

-- 
1.9.1
