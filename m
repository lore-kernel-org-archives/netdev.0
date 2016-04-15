From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 00/11] devlink: add support for shared buffer configuration and control
Date: Fri, 15 Apr 2016 09:51:42 +0200
Message-ID: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35786 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbcDOHv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 03:51:57 -0400
Received: by mail-wm0-f54.google.com with SMTP id a140so19470506wma.0
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 00:51:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Jiri Pirko (11):
  devlink: fix "devlink port" help message
  list: add list_for_each_entry_reverse macro
  list: add list_add_tail helper
  devlink: introduce pr_out_port_handle helper
  devlink: introduce helper to print out nice names (ifnames)
  devlink: split dl_argv_parse_put to parse and put parts
  devlink: introduce dump filtering function
  devlink: allow to parse both devlink and port handle in the same time
  devlink: implement shared buffer support
  devlink: implement shared buffer occupancy control
  devlink: add manpage for shared buffer

 devlink/devlink.c          | 1310 +++++++++++++++++++++++++++++++++++++++++---
 include/linux/devlink.h    |   63 +++
 include/list.h             |   16 +
 man/man8/devlink-dev.8     |    2 +
 man/man8/devlink-monitor.8 |    1 +
 man/man8/devlink-port.8    |    2 +
 man/man8/devlink-sb.8      |  313 +++++++++++
 man/man8/devlink.8         |    5 +
 8 files changed, 1636 insertions(+), 76 deletions(-)
 create mode 100644 man/man8/devlink-sb.8

-- 
2.5.5
