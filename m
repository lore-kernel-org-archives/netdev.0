From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 0/2] team: two RCU fixups
Date: Wed, 20 Jun 2012 17:31:59 +0200
Message-ID: <1340206321-5986-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com,
	paulmck@linux.vnet.ibm.com, wfg@linux.intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53518 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654Ab2FTPcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 11:32:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (2):
  team: use rcu_access_pointer to access RCU pointer by writer
  team: use RCU_INIT_POINTER for NULL assignment of RCU pointer

 drivers/net/team/team_mode_activebackup.c |    7 +++++--
 drivers/net/team/team_mode_loadbalance.c  |   10 ++++++----
 2 files changed, 11 insertions(+), 6 deletions(-)

-- 
1.7.10.4
