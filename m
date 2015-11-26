From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2015-11-26
Date: Thu, 26 Nov 2015 16:39:12 +0100
Message-ID: <1448552352.2167.14.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[resending with correct netdev address, not sure how that ended up in
my autocompletion address book ... sorry about that!]

Hi Dave,

Sorry for being so late. These have been pending for a while (and in
fact in linux-next too, I asked to be added there recently :) ).

Let me know if there's any problem.

Thanks,
johannes


The following changes since commit
17c790a60dad11c0193127e83ac8e183b4fed1a2:

=C2=A0 Merge branch 'mv88e6060-fixes' (2015-11-15 20:16:26 -0500)

are available in the git repository at:

=C2=A0 git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git
tags/mac80211-for-davem-2015-11-26

for you to fetch changes up to
5ff3ca2888940533dcd50212cf0be7049fee979c:

=C2=A0 mac80211: don't teardown sdata on sdata stop (2015-11-20 11:40:5=
0
+0100)

----------------------------------------------------------------
A small set of fixes for 4.4:
=C2=A0* remove NL80211_FEATURE_FULL_AP_CLIENT_STATE again, it
=C2=A0=C2=A0=C2=A0was broken and needs more work, we'll enable it for 4=
=2E5
=C2=A0* fix call_rcu() induced use-after-reset/free in mesh
=C2=A0=C2=A0=C2=A0(that was suddenly causing issues in certain tests)
=C2=A0* always request block-ack window size 64 as we found
=C2=A0=C2=A0=C2=A0some APs will otherwise crash (really ...)
=C2=A0* fix P2P-Device teardown sequence to avoid restarting
=C2=A0=C2=A0=C2=A0with uninitialized data

----------------------------------------------------------------
Eliad Peller (1):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: don't teardown sdata on s=
data stop

Emmanuel Grumbach (1):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: ensure we don't update tx=
 power on a non-running sdata

Gregory Greenman (1):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: always set the buf_size i=
n AddBA req to 64

Johannes Berg (2):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: don't advertise NL80211_F=
EATURE_FULL_AP_CLIENT_STATE
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: mesh: fix call_rcu() usag=
e

=C2=A0include/net/mac80211.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 6 +++=
+--
=C2=A0net/mac80211/agg-tx.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| =
3 ++-
=C2=A0net/mac80211/iface.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0| 5 +++--
=C2=A0net/mac80211/main.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0| 3 +--
=C2=A0net/mac80211/mesh_pathtbl.c | 8 ++++----
=C2=A05 files changed, 14 insertions(+), 11 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
