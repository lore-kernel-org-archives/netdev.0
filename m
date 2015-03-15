From: sfeldma@gmail.com
Subject: [PATCH net-next 0/5] switchdev: add swdev ops
Date: Sat, 14 Mar 2015 23:15:02 -0700
Message-ID: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:35715 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbbCOGON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 02:14:13 -0400
Received: by pdbop1 with SMTP id op1so25868709pdb.2
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2015 23:14:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Per discussions at netconf, move switchdev ndo ops to a new swdev_ops to
keep ndo namespace clean and maintain switchdev-related ops into one place.

There are no functional changes here; just shuffling ops around for better
organization.

Scott Feldman (5):
  switchdev: add swdev ops
  switchdev: use new swdev ops
  rocker: move to new swdev ops
  dsa: move to new swdev ops
  netdev: remove ndo ops for switchdev

 drivers/net/ethernet/rocker/rocker.c |   64 +++++++++++++++++++---------------
 include/linux/netdevice.h            |   41 ++--------------------
 include/net/switchdev.h              |   38 ++++++++++++++++++++
 net/dsa/slave.c                      |    8 +++--
 net/switchdev/switchdev.c            |   42 +++++++++++-----------
 5 files changed, 104 insertions(+), 89 deletions(-)

-- 
1.7.10.4
