From: sfeldma@gmail.com
Subject: [PATCH net-next 0/4] switchdev: more (minor) cleanups
Date: Tue, 12 May 2015 23:03:50 -0700
Message-ID: <1431497034-22153-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36108 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbbEMGCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 02:02:50 -0400
Received: by pdea3 with SMTP id a3so40549999pde.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 23:02:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Fix some sparse warnings and include some documentation review comments that
didn't get picked up in the switchdev Spring Cleanup series.

Scott Feldman (4):
  switchdev: sparse warning: make __switchdev_port_obj_add static
  switchdev: sparse warning: pass ipv4 fib dst as network-byte order
  switchdev: align comment with other comments in block
  switchdev: apply review comments on documentation

 Documentation/networking/switchdev.txt |    7 +++++--
 drivers/net/ethernet/rocker/rocker.c   |    7 ++++---
 include/net/switchdev.h                |    2 +-
 net/switchdev/switchdev.c              |    7 ++++---
 4 files changed, 14 insertions(+), 9 deletions(-)

-- 
1.7.10.4
