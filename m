From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] team: fix port list dump for big number of ports
Date: Wed, 29 May 2013 17:02:55 +0200
Message-ID: <1369839777-19158-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, sasha.levin@oracle.com,
	akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:62264 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966175Ab3E2PDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 11:03:01 -0400
Received: by mail-we0-f179.google.com with SMTP id m46so6524061wev.10
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 08:03:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (2):
  list: introduce list_first_entry_or_null
  team: fix port list dump for big number of ports

 drivers/net/team/team.c |  7 ++++---
 include/linux/list.h    | 11 +++++++++++
 2 files changed, 15 insertions(+), 3 deletions(-)

-- 
1.7.11.7
