From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 0/4] Introduce BPF-based TX port selecting for Team device
Date: Sat, 31 Mar 2012 23:01:18 +0200
Message-ID: <1333227682-10235-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	raise.sail@gmail.com, nuno.martins@caixamagica.pt, matt@ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8255 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752838Ab2CaVBf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Mar 2012 17:01:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (4):
  filter: Allow to create sk-unattached filters
  filter: add XOR operation
  team: add binary option type
  team: add loadbalance mode

 drivers/net/team/Kconfig                 |   11 ++
 drivers/net/team/Makefile                |    1 +
 drivers/net/team/team.c                  |   28 ++++-
 drivers/net/team/team_mode_loadbalance.c |  188 ++++++++++++++++++++++++++++++
 include/linux/filter.h                   |    7 +-
 include/linux/if_team.h                  |    8 ++
 net/core/filter.c                        |   70 +++++++++++-
 7 files changed, 304 insertions(+), 9 deletions(-)
 create mode 100644 drivers/net/team/team_mode_loadbalance.c

-- 
1.7.9.1
