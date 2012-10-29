From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 202-10-29
Date: Mon, 29 Oct 2012 09:58:01 +0100
Message-ID: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
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

Hello David,

this is again our first set of changes intended for net-next/linux-3.8.
With respect to the previous changeset we substituted the patch changing the
BAT_ATTR_HIF_UINT macro with a new one that removes it (we will re-add such
macro together with the user).
The rest is exactly the same as before.

Thank you very much,
		Antonio


The following changes since commit a932657f51eadb8280166e82dc7034dfbff3985a:

  net: sierra: shut up sparse restricted type warnings (2012-10-28 19:09:02 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 0aca86cd92282359d2f7202804bd92e7d092c04e:

  batman-adv: add kernel-doc for enum batadv_dbg_level (2012-10-29 09:42:51 +0100)

----------------------------------------------------------------
included changes:
- some code cleanups and minor fixes (3 of them were reported by Coverity)
- 'struct hard_iface' re-shaping to improve multi-protocol support
- ECTP packets silent drop
- transfer the WIFI flag on clients in case of roaming

----------------------------------------------------------------
Antonio Quartulli (8):
      batman-adv: use check_unicast_packet() in recv_roam_adv()
      batman-adv: return proper value in case of hash_add failure
      batman-adv: properly store the roaming time
      batman-adv: print packets re-routing on DBG_TT and ratelimit it
      batman-adv: check for more space before accessing the skb
      batman-adv: properly convert flag into a boolean value
      batman-adv: pass the WIFI flag from the local to global entry
      batman-adv: add kernel-doc for enum batadv_dbg_level

Marek Lindner (2):
      batman-adv: split hard_iface struct for each routing protocol
      batman-adv: consolidate duplicated primary_if checking code

Simon Wunderlich (1):
      batman-adv: don't allow ECTP traffic on batman-adv

Sven Eckelmann (5):
      batman-adv: Remove unused define BAT_ATTR_HIF_UINT
      batman-adv: Set special lockdep classes to avoid lockdep warning
      batman-adv: Remove extra check in batadv_bit_get_packet
      batman-adv: Check return value of try_module_get
      batman-adv: Only increase refcounter once for alternate router

 net/batman-adv/bat_iv_ogm.c            | 43 ++++++++++---------
 net/batman-adv/bitarray.c              | 23 +++++-----
 net/batman-adv/bridge_loop_avoidance.c | 36 +++-------------
 net/batman-adv/debugfs.c               |  6 ++-
 net/batman-adv/gateway_client.c        | 19 ++-------
 net/batman-adv/hard-interface.c        |  4 +-
 net/batman-adv/icmp_socket.c           | 12 ++++--
 net/batman-adv/main.c                  | 46 +++++++++++++++-----
 net/batman-adv/main.h                  | 19 ++++++---
 net/batman-adv/originator.c            | 19 ++-------
 net/batman-adv/routing.c               | 54 +++++++++---------------
 net/batman-adv/soft-interface.c        | 56 ++++++++++++++++++++++++-
 net/batman-adv/sysfs.c                 | 49 ----------------------
 net/batman-adv/translation-table.c     | 77 +++++++++++++++++-----------------
 net/batman-adv/translation-table.h     |  6 +--
 net/batman-adv/types.h                 | 16 +++++--
 16 files changed, 238 insertions(+), 247 deletions(-)
