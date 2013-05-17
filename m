From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request for net: batman-adv 2013-05-17
Date: Fri, 17 May 2013 10:10:10 +0200
Message-ID: <1368778211-2142-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
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

here you have one fix intended for net/linux-3.10.
This patch is fixing a global fault protection that can be triggered on m=
odule
removal due to the double invocation of call_rcu() in chain.

While fixing, the patch is also adding some kernel doc to the changed fun=
ctions.
Consider queueing this patch to -stable.



Please pull or let me know if there is any problem!

Thank you,
	Antonio


The following changes since commit b0ce3508b25ea6fa10ae3ca254de1d695b5217=
02:

  bonding: allow TSO being set on bonding master (2013-05-16 15:02:01 -07=
00)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 72822225bd41320a98f5d7cde38317766e18983f:

  batman-adv: Fix rcu_barrier() miss due to double call_rcu() in TT code =
(2013-05-17 09:54:28 +0200)

----------------------------------------------------------------
Included changes:
- fix global protection fault by avoiding double call_rcu

----------------------------------------------------------------
Linus L=C3=BCssing (1):
      batman-adv: Fix rcu_barrier() miss due to double call_rcu() in TT c=
ode

 net/batman-adv/originator.c        | 16 ++++++++++++++++
 net/batman-adv/originator.h        |  1 +
 net/batman-adv/translation-table.c |  7 ++++++-
 3 files changed, 23 insertions(+), 1 deletion(-)
