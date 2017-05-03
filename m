From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v2 0/2] devlink: Add support for pipeline
Date: Wed,  3 May 2017 13:25:21 +0200
Message-ID: <1493810723-2536-1-git-send-email-jiri@resnulli.us>
Cc: arkadis@mellanox.com, stephen@networkplumber.org,
        davem@davemloft.net, mlxsw@mellanox.com, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33102 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751570AbdECLZ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 07:25:26 -0400
Received: by mail-wm0-f67.google.com with SMTP id y10so12038620wmh.0
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 04:25:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Arkadi says:

Add support for pipeline debug (dpipe). As a preparation step the netlink
attribute validation was changed before adding new dpipe attributes.
---
v1->v2
- Change netlink attribute validation. 
- Fix commit message typos

Arkadi Sharshevsky (2):
  devlink: Change netlink attribute validation
  devlink: Add support for pipeline debug (dpipe)

 devlink/devlink.c | 1450 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 1281 insertions(+), 169 deletions(-)

-- 
2.7.4
