From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2016-04-06
Date: Wed,  6 Apr 2016 15:19:58 +0200
Message-ID: <1459948799-22032-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

=46irst set of fixes for 4.6. Nothing really stands out.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 05cf8077e54b20dddb756eaa26f3aeb5c38d=
d3cf:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-0=
4-01 20:03:33 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags=
/mac80211-for-davem-2016-04-06

for you to fetch changes up to b4201cc4fc6e1c57d6d306b1f787865043d60129=
:

  mac80211: fix "warning: =E2=80=98target_metric=E2=80=99 may be used u=
ninitialized" (2016-04-06 15:10:25 +0200)

----------------------------------------------------------------
=46or the current RC series, we have the following fixes:
 * TDLS fixes from Arik and Ilan
 * rhashtable fixes from Ben and myself
 * documentation fixes from Luis
 * U-APSD fixes from Emmanuel
 * a TXQ fix from Felix
 * and a compiler warning suppression from Jeff

----------------------------------------------------------------
Arik Nemtsov (3):
      mac80211: TDLS: always downgrade invalid chandefs
      mac80211: TDLS: change BW calculation for WIDER_BW peers
      mac80211: recalc min_def chanctx even when chandef is identical

Ben Greear (1):
      mac80211: ensure no limits on station rhashtable

Emmanuel Grumbach (2):
      mac80211: don't send deferred frames outside the SP
      mac80211: close the SP when we enqueue frames during the SP

=46elix Fietkau (1):
      mac80211: fix AP buffered multicast frames with queue control and=
 txq

Ilan Peer (1):
      mac80211: Fix BW upgrade for TDLS peers

Jeff Mahoney (1):
      mac80211: fix "warning: =E2=80=98target_metric=E2=80=99 may be us=
ed uninitialized"

Johannes Berg (1):
      mac80211: properly deal with station hashtable insert errors

Luis de Bethencourt (2):
      mac80211: add doc for RX_FLAG_DUP_VALIDATED flag
      mac80211: remove description of dropped member

 include/net/mac80211.h     |  2 ++
 net/mac80211/chan.c        |  4 +++-
 net/mac80211/ieee80211_i.h |  4 ++++
 net/mac80211/mesh_hwmp.c   |  2 +-
 net/mac80211/sta_info.c    | 14 +++++++++-----
 net/mac80211/sta_info.h    |  1 -
 net/mac80211/tdls.c        | 43 +++++++++++++++++++++++++++++++++++---=
-----
 net/mac80211/tx.c          | 13 +++++++++----
 net/mac80211/vht.c         | 30 +++++++++++++++++++++++++-----
 9 files changed, 88 insertions(+), 25 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
