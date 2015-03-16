From: sfeldma@gmail.com
Subject: [PATCH net-next v3 0/3] switchdev: add swdev ops
Date: Sun, 15 Mar 2015 21:07:13 -0700
Message-ID: <1426478836-60788-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36497 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbbCPEG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:06:27 -0400
Received: by pdbcz9 with SMTP id cz9so46091616pdb.3
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 21:06:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

v3:

 - Fix missing include for DSA build

v2:

 - Per Simon's review, squash some of the dependent commits into one to
   make series git bisect safe.

v1:

Per discussions at netconf, move switchdev ndo ops to a new swdev_ops to
keep ndo namespace clean and maintain switchdev-related ops into one place.

There are no functional changes here; just shuffling ops around for better
organization.

Scott Feldman (3):
  switchdev: add swdev ops
  switchdev: use new swdev ops
  netdev: remove ndo ops for switchdev

 drivers/net/ethernet/rocker/rocker.c |   64 +++++++++++++++++++---------------
 include/linux/netdevice.h            |   41 ++--------------------
 include/net/switchdev.h              |   38 ++++++++++++++++++++
 net/dsa/slave.c                      |    9 +++--
 net/switchdev/switchdev.c            |   42 +++++++++++-----------
 5 files changed, 105 insertions(+), 89 deletions(-)

-- 
1.7.10.4
