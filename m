From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request: batman-adv 2012-09-25
Date: Tue, 25 Sep 2012 17:57:15 +0200
Message-ID: <1348588637-18441-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:64034 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756693Ab2IYP5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 11:57:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here are two fixes (the last set) we would to propose for net/linux-3.6=
=2E

The one from Def fixes a wrong behaviour of batman-adv in case of virtu=
al
interface mac address change, while the other from Lin=C3=BCs fixes a p=
roblem in the
route selection which can lead to a continuous route flapping under cer=
tain
conditions.

We would also like to enqueue both patches for sending to stable-3.5.

During merge with net/master you will hit a conflict. I'm going to send=
 some
instructions on how to solve it.

Thank you very much,
		Antonio



The following changes since commit 2b018d57ff18e5405823e5cb59651a5b4d94=
6d7b:

  pppoe: drop PPPOX_ZOMBIEs in pppoe_release (2012-09-22 15:49:31 -0400=
)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 7caf69fb9c5017df01945a1861c042f6aa08edeb=
:

  batman-adv: Fix symmetry check / route flapping in multi interface se=
tups (2012-09-23 23:12:49 +0200)

----------------------------------------------------------------
Included fixes:
- fix the behaviour of batman-adv in case of virtual interface MAC chan=
ge event
- fix symmetric link check in neighbour selection

----------------------------------------------------------------
Def (1):
      batman-adv: Fix change mac address of soft iface.

Linus L=C3=BCssing (1):
      batman-adv: Fix symmetry check / route flapping in multi interfac=
e setups

 net/batman-adv/bat_iv_ogm.c     | 13 +++++++------
 net/batman-adv/soft-interface.c |  7 +++++--
 2 files changed, 12 insertions(+), 8 deletions(-)
