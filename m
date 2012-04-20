From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 0/3] team: couple patches
Date: Fri, 20 Apr 2012 16:42:03 +0200
Message-ID: <1334932926-23996-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47343 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754707Ab2DTOmM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 10:42:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (3):
  team: lb: let userspace care about port macs
  team: allow to enable/disable ports
  team: add per-port option for enabling/disabling ports

 drivers/net/team/team.c                  |   75 +++++++++++++++++++++++------
 drivers/net/team/team_mode_loadbalance.c |   14 +-----
 drivers/net/team/team_mode_roundrobin.c  |    2 +-
 include/linux/if_team.h                  |   15 +++---
 4 files changed, 69 insertions(+), 37 deletions(-)

-- 
1.7.9.1
