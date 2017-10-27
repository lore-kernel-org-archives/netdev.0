From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v4 00/10] Adding permanent config get/set to devlink
Date: Fri, 27 Oct 2017 16:54:04 -0400
Message-ID: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:38539 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932490AbdJ0Uye (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 16:54:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v3:

* Using union instead of void * to pass parameter values to/from drivers.
* Updated parameter comments / naming and added enum for enable/disable
  to add clarity.
* Various code cleanup in bnxt:
  - change hwrm call to use mutex protected version
  - use roundup() macro
  - remove unnecessary error messages
  - change mechanism to check for parameter-not-found
  - cleanup merge w/ switchdev eswitch devlink functions
  - rebased with Michael Chan's recent bnxt changes in net-next.

Suggested changes not implemented:

* re: val8 = val32 "Don't you need explicit castings for these kind of
  assignments to prevent warnings?" -- No, I don't think explicit castings
  are necessary here; I don't get any compiler warnings (w/ gcc 5.4.0)
