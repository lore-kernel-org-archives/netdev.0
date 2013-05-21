From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: (no subject)
Date: Tue, 21 May 2013 21:53:54 +0200
Message-ID: <1369166035-585-1-git-send-email-ordex@autistici.org>
References: <pull request for net: batman-adv 2013-05-21>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <pull request for net: batman-adv 2013-05-21>
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

this is another small patch for net/linux-3.10. It is preventing a double=
 free
of the bat_counters in case of mesh initialisation failure.

Sorry for sending such small pull requests (I guess this is not that bad =
since
they target net :-)), but these are small glitches we are finding while t=
esting
new features.

Please pull or let me know if there is any problem.

Thanks a lot,
	Antonio


The following changes since commit 3ccfc1b1d2fa78f8ece83646027982916fcc79=
4b:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/linville/wireless (2013-05-20 14:05:22 -0700)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to f69ae770e74df420fbcf93aae81b30a5dcc73b7d:

  batman-adv: Avoid double freeing of bat_counters (2013-05-21 21:34:36 +=
0200)

----------------------------------------------------------------
Included change:
- fix double free in case of failure during mesh initialisation

----------------------------------------------------------------
Martin Hundeb=C3=B8ll (1):
      batman-adv: Avoid double freeing of bat_counters

 net/batman-adv/main.c           | 1 +
 net/batman-adv/soft-interface.c | 1 +
 2 files changed, 2 insertions(+)
