From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: pull request: batman-adv 2011-12-12
Date: Mon, 12 Dec 2011 19:31:44 +0800
Message-ID: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

here comes the next batch I'd like to get the pulled into net-next-2.6/3.3.
We have a couple of minor fixes for unregister_netdevice(), compat flags,
return value checks and a readme update. Plus the regression fix from Dan
that addresses a bug introduced with the previous batch. Security 
researcher Paul Kot checked our kernelland / user space communication and
found a subtle bug which would make batman-adv write to memory locations
it should not write to. However, he did not find a way to exploit this
bug, therefore we classified it as "non-critical". Please let us know if
that is not ok with you.

Thanks,
Marek


The following changes since commit 76e8d7b0d1b0091929e8cd18551a87b6bb6ef2c1:

  batman-adv: Fix range check for expected packets (2011-11-20 13:08:35 +0100)

are available in the git repository at:
  git://git.open-mesh.org/linux-merge.git batman-adv/next

Antonio Quartulli (3):
      batman-adv: create a common substructure for tt_global/local_entry
      batman-adv: generalise tt_local_reset_flags()
      batman-adv: format multi-line if in the correct way

Dan Carpenter (1):
      batman-adv: remove extra negation in gw_out_of_range()

Marek Lindner (2):
      batman-adv: report compat_version in version field in case of version mismatch
      batman-adv: readme update (mention ap isolation and new log level)

Paul Kot (1):
      batman-adv: bat_socket_read missing checks

Simon Wunderlich (2):
      batman-adv: check return value for hash_add()
      batman-adv: use unregister_netdevice() when softif_create fails

Sven Eckelmann (2):
      batman-adv: Directly check read of icmp packet in copy_from_user
      batman-adv: Only write requested number of byte to user buffer

 Documentation/networking/batman-adv.txt |    7 +-
 net/batman-adv/gateway_client.c         |    2 +-
 net/batman-adv/icmp_socket.c            |   14 +-
 net/batman-adv/routing.c                |    3 +-
 net/batman-adv/soft-interface.c         |    2 +-
 net/batman-adv/translation-table.c      |  336 ++++++++++++++++++-------------
 net/batman-adv/types.h                  |   14 +-
 net/batman-adv/vis.c                    |    6 +-
 8 files changed, 216 insertions(+), 168 deletions(-)
