From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request [net]: batman-adv 20150616
Date: Tue, 16 Jun 2015 21:06:22 +0200
Message-ID: <1434481584-1275-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:12566 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932119AbbFPTIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 15:08:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request intended for net/linux-4.1.
I know it is rather late in the release cycle, but the fixes are
pretty small and they were worth being sent now.

Patch 1/2 fixes an overflow of a u32 variable that may happen while
computing the metric to select the best batman-GW in the network.
** It would be great if this patch could be queued for inclusion in
any stable release >= 3.2


Patch 2/2 prevents the Distributed ARP Table from forging unwanted
ARP replies on behalf of another host that may fool an Ethernet switch
sitting behind batman-adv.
** It would be great if this patch could be queued for inclusion in
any stable release >= 3.8


Please pull or let me know if something is wrong

Thanks a lot,
	Antonio



The following changes since commit ac0a72a3e6e8d817f60ce4d9a8f3b43dc256d847:

  net/mlx4_core: Disable Granular QoS per VF under IB/Eth VPI configuration (2015-06-15 16:42:57 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to c065d51055924f6daad8e16307c364602b0f9805:

  batman-adv: avoid DAT to mess up LAN state (2015-06-16 11:13:12 +0200)

----------------------------------------------------------------
Included changes:
- fix gateway selection metric overflow
- avoid the Distriubted ARP Table to fool Ethernet switches by forging
  unexpected packets

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: avoid DAT to mess up LAN state

Ruben Wisniewski (1):
      batman-adv: Avoid u32 overflow during gateway select

 net/batman-adv/distributed-arp-table.c | 18 +++++++++++++-----
 net/batman-adv/gateway_client.c        |  2 +-
 2 files changed, 14 insertions(+), 6 deletions(-)
