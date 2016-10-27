From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 00/17] pull request for net-next: batman-adv
	2016-10-27
Date: Thu, 27 Oct 2016 21:01:33 +0200
Message-ID: <20161027190150.7880-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi David,

this is our first feature pull request for batman-adv (mostly containing
code cleanup stuff), there are at least two more to come.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 29fbff8698fc0ac1a1d74584b258e0bf18b469f9:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-10-13 21:40:23 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20161027

for you to fetch changes up to 4c7da0f6dbcde2431d773ce03cde5e7abede54e0:

  batman-adv: Avoid precedence issues in macros (2016-10-19 08:37:54 +0200)

----------------------------------------------------------------
This code cleanup patchset includes the following changes (chronological
order):

 - bump version strings, by Simon Wunderlich

 - README updates/clean up, by Sven Eckelmann (4 patches)

 - Code clean up and restructuring by Sven Eckelmann (2 patches)

 - Kerneldoc fix in forw_packet structure, by Linus Luessing

 - Remove unused argument in dbg_arp, by Antonio Quartulli

 - Add support to build batman-adv without wireless, by Linus Luessing

 - Restructure error handling for is_ap_isolated, by Markus Elfring

 - Remove unused initialization in various functions, by Sven Eckelmann

 - Use better names for fragment and gateway list heads, by Sven
   Eckelmann (2 patches)

 - Convert to octal permissions for files, by Sven Eckelmann

 - Avoid precedence issues for some macros, by Sven Eckelmann

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: remove unsed argument from batadv_dbg_arp() function

Linus Lüssing (2):
      batman-adv: fix batadv_forw_packet kerneldoc for list attribute
      batman-adv: Allow selecting BATMAN V if CFG80211 is not built

Markus Elfring (1):
      batman-adv: Less function calls in batadv_is_ap_isolated() after error detection

Simon Wunderlich (1):
      batman-adv: Start new development cycle

Sven Eckelmann (12):
      batman-adv: Add B.A.T.M.A.N. V sysfs files to README
      batman-adv: Add network_coding and mcast sysfs files to README
      batman-adv: Add dat, mcast, nc and neighbor debugfs files to README
      batman-adv: Document new nc, mcast and tpmeter log levels
      batman-adv: Remove unused function batadv_hash_delete
      batman-adv: Move batadv_sum_counter to soft-interface.c
      batman-adv: Remove unused batadv_icmp_user_cmd_type
      batman-adv: Remove needless init of variables on stack
      batman-adv: Use proper name for fragments list head
      batman-adv: Use proper name for gateway list head
      batman-adv: Use octal permissions instead of macros
      batman-adv: Avoid precedence issues in macros

 Documentation/networking/batman-adv.txt | 35 ++++++++++++----------
 net/batman-adv/Kconfig                  |  2 +-
 net/batman-adv/bat_iv_ogm.c             |  6 ++--
 net/batman-adv/bat_v.c                  |  8 ++---
 net/batman-adv/bat_v_ogm.c              |  4 +--
 net/batman-adv/debugfs.c                | 26 ++++++++--------
 net/batman-adv/distributed-arp-table.c  | 17 ++++-------
 net/batman-adv/fragmentation.c          | 18 +++++------
 net/batman-adv/fragmentation.h          |  2 +-
 net/batman-adv/gateway_client.c         |  9 +++---
 net/batman-adv/hash.h                   | 30 -------------------
 net/batman-adv/icmp_socket.c            |  5 ++--
 net/batman-adv/log.c                    |  4 +--
 net/batman-adv/log.h                    | 12 ++++----
 net/batman-adv/main.c                   |  2 +-
 net/batman-adv/main.h                   | 27 ++---------------
 net/batman-adv/network-coding.c         |  8 ++---
 net/batman-adv/originator.c             | 10 +++----
 net/batman-adv/packet.h                 | 12 +-------
 net/batman-adv/send.c                   |  2 +-
 net/batman-adv/soft-interface.c         | 21 +++++++++++++
 net/batman-adv/sysfs.c                  | 53 ++++++++++++++-------------------
 net/batman-adv/translation-table.c      | 25 +++++++---------
 net/batman-adv/types.h                  | 16 +++++-----
 24 files changed, 149 insertions(+), 205 deletions(-)
