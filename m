From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request for net: batman-adv 2013-08-10
Date: Sat, 10 Aug 2013 23:08:00 +0200
Message-ID: <1376168881-4079-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:44241 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757704Ab3HJVfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 17:35:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have one fix intended for net/linux-3.11.

To avoid kernel paging errors, this patch takes care of re-assigning th=
e value
of skb->data to the related pointers after that the skb has been re-all=
ocated.


Please pull or let me know of any problem!

Thank you,
	Antonio



The following changes since commit 645359930231d5e78fd3296a38b98c1a658a=
7ade:

  rtnetlink: Fix inverted check in ndo_dflt_fdb_del() (2013-08-10 01:24=
:12 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 9d2c9488cedb666bc8206fbdcdc1575e0fbc5929=
:

  batman-adv: fix potential kernel paging errors for unicast transmissi=
ons (2013-08-10 22:55:42 +0200)

----------------------------------------------------------------
Included change:
- reassign pointers to data after skb reallocation to avoid kernel pagi=
ng errors

----------------------------------------------------------------
Linus L=C3=BCssing (1):
      batman-adv: fix potential kernel paging errors for unicast transm=
issions

 net/batman-adv/bridge_loop_avoidance.c |  2 ++
 net/batman-adv/gateway_client.c        | 13 ++++++++++++-
 net/batman-adv/gateway_client.h        |  3 +--
 net/batman-adv/soft-interface.c        |  9 ++++++++-
 net/batman-adv/unicast.c               | 13 ++++++++++---
 5 files changed, 33 insertions(+), 7 deletions(-)
