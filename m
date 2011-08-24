From: Marek Lindner <lindner_marek@yahoo.de>
Subject: pull request: batman-adv 2011-08-24
Date: Wed, 24 Aug 2011 15:00:30 +0200
Message-ID: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm4-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.230]:47429 "HELO
	nm4-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751090Ab1HXNAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 09:00:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

the following 8 patches constitute the first batch I'd like to get the pulled
into net-next-2.6/3.2. They bring a new feature (AP isolation on the mesh
layer), some minor cleanups, spelling fixes and some additional debugfs 
output. 

Thanks,
Marek


The following changes since commit 322a8b034003c0d46d39af85bf24fee27b902f48:

  Linux 3.1-rc1 (2011-08-07 18:23:30 -0700)

are available in the git repository at:
  git://git.open-mesh.org/linux-merge.git batman-adv/next

Antonio Quartulli (6):
      batman-adv: hash_add() has to discriminate on the return value
      batman-adv: correct several typ0s in the comments
      batman-adv: detect clients connected through a 802.11 device
      batman-adv: implement AP-isolation on the receiver side
      batman-adv: implement AP-isolation on the sender side
      batman-adv: print client flags in the local/global transtables output

Marek Lindner (2):
      batman-adv: reuse tt_len() to calculate tt buffer length
      batman-adv: merge update_transtable() into tt related code

 Documentation/ABI/testing/sysfs-class-net-mesh |    8 +
 net/batman-adv/aggregation.h                   |    3 +-
 net/batman-adv/bat_sysfs.c                     |    2 +
 net/batman-adv/bitarray.c                      |    6 +-
 net/batman-adv/gateway_client.c                |   10 +-
 net/batman-adv/hard-interface.c                |   34 ++++-
 net/batman-adv/hard-interface.h                |    1 +
 net/batman-adv/hash.h                          |   25 +++-
 net/batman-adv/main.c                          |    2 +-
 net/batman-adv/main.h                          |    6 +-
 net/batman-adv/originator.c                    |    2 +-
 net/batman-adv/packet.h                        |    1 +
 net/batman-adv/routing.c                       |   77 +--------
 net/batman-adv/send.c                          |   10 +-
 net/batman-adv/soft-interface.c                |   13 +-
 net/batman-adv/translation-table.c             |  199 ++++++++++++++++++++----
 net/batman-adv/translation-table.h             |   21 ++--
 net/batman-adv/types.h                         |    5 +-
 net/batman-adv/unicast.c                       |    6 +-
 net/batman-adv/unicast.h                       |    2 +-
 net/batman-adv/vis.c                           |    6 +-
 21 files changed, 291 insertions(+), 148 deletions(-)
