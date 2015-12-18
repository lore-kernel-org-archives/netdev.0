From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211-next 2015-12-18
Date: Fri, 18 Dec 2015 19:49:42 +0100
Message-ID: <1450464582.2849.68.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Before we all go on vacation/holidays, I have a few bugfixes for
net-next. The remain-on-channel ones are quite necessary since Ilan's
patch broke things quite a bit, causing crashes.

If the issue with the strange mail formatting persists let me know and
I'll send these through some other client in the future.

Enjoy the holidays and happy New Year :)

Thanks,
johannes


The following changes since commit 1b894521e60c1b91db1e8ba1278660e5c89f=
1b5f:

=C2=A0 mac80211: handle HW ROC expired properly (2015-12-07 11:06:37 +0=
100)

are available in the git repository at:

=C2=A0 git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-nex=
t.git tags/mac80211-next-for-davem-2015-12-18

for you to fetch changes up to c45932df56120a73b05f391be9730185eb51eecf=
:

=C2=A0 regulatory: fix world regulatory domain data (2015-12-11 17:42:0=
6 +0100)

----------------------------------------------------------------
A few more updates for the next cycle:
=C2=A0* remove pretty much unused and useless REG_DEBUG option
=C2=A0* make regdomain messages debugging only
=C2=A0* fix two bugs in the new remain-on-channel code
=C2=A0* fix the world regdomain data for consistency

----------------------------------------------------------------
Dave Young (1):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0wireless: change cfg80211 regulator=
y domain info as debug messages

Johannes Berg (4):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: recalculate SW ROC only w=
hen needed
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac80211: fix remain-on-channel can=
cellation
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0cfg80211: remove CFG80211_REG_DEBUG
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0regulatory: fix world regulatory do=
main data

=C2=A0net/mac80211/offchannel.c |=C2=A0=C2=A012 ++--
=C2=A0net/wireless/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=
=A013 ----
=C2=A0net/wireless/reg.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
| 167 ++++++++++++++++------------------------------
=C2=A03 files changed, 64 insertions(+), 128 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
