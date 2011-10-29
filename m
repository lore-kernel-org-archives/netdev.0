From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: pull request: batman-adv 2011-10-29
Date: Sat, 29 Oct 2011 10:06:43 +0200
Message-ID: <1319875606-7794-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
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

we have 3 more bugfixes for you which we would like to see getting
merged into net-next/linux-3.2. They fix refcounting, a crash on
module unload and a protocol handling bug.

Thanks,
Marek

The following changes since commit 9d8523931f7f5eb8900077f0da0fbe6b8ad0010b:

  batman-adv: correctly set the data field in the TT_REPONSE packet (2011-10-18 22:45:10 +0200)

are available in the git repository at:
  git://git.open-mesh.org/linux-merge.git batman-adv/maint

Antonio Quartulli (1):
      batman-adv: unify hash_entry field position in tt_local/global_entry

Simon Wunderlich (2):
      batman-adv: remove references for global tt entries
      batman-adv: add sanity check when removing global tts

 net/batman-adv/translation-table.c |   17 ++++++++++++++++-
 net/batman-adv/types.h             |    4 ++--
 2 files changed, 18 insertions(+), 3 deletions(-)
