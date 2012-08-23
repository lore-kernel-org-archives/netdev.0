From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] team: couple of fixes
Date: Thu, 23 Aug 2012 15:26:50 +0200
Message-ID: <1345728413-10298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, brouer@redhat.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:48515 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933605Ab2HWN1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:27:06 -0400
Received: by weyx8 with SMTP id x8so400008wey.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 06:27:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ vlan helper

Jiri Pirko (3):
  teamd: don't print warn message on -ESRCH during event send
  vlan: add helper which can be called to se it device is used by vlan
  team: do not allow to add VLAN challenged port when vlan is used

 drivers/net/team/team.c | 15 +++++++++++----
 include/linux/if_vlan.h |  9 +++++++--
 net/8021q/vlan_core.c   |  6 ++++++
 3 files changed, 24 insertions(+), 6 deletions(-)

-- 
1.7.11.4
