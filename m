From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: pull request: batman-adv 2011-10-18 (more regression
	fixes)
Date: Tue, 18 Oct 2011 23:01:07 +0200
Message-ID: <1318971669-941-1-git-send-email-lindner_marek@yahoo.de>
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

we have identified and fixed 2 more critical bugs in the linux-3.1
code base. We are somewhat late in the 3.1 release cycle but hoped
to take advantage of the delayed release to get these patches 
included before the final version is out. If not I will have to
send these patches to stable@ and would like to see these patches
applied to net-next-2.6/3.2. No merge conflicts are to be expected.
Let us know what works best for you.

Thanks,
Marek

The following changes since commit 8b267b312df9343fea3bd679c509b36214b5a854:

  batman-adv: do_bcast has to be true for broadcast packets only (2011-09-22 20:27:10 +0200)

are available in the git repository at:
  git://git.open-mesh.org/linux-merge.git batman-adv/maint

Antonio Quartulli (2):
      batman-adv: fix tt_local_reset_flags() function
      batman-adv: correctly set the data field in the TT_REPONSE packet

 net/batman-adv/translation-table.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)
