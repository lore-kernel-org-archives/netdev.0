From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 0/2 net] Bug fixes for batman-adv 2012-06-23
Date: Sat, 23 Jun 2012 17:30:57 +0200
Message-ID: <1340465459-2949-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:53259 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750Ab2FWPbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 11:31:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here are two fixes intended for net/linux-3.5.

Patch 1 is a fix for the AP-Isolation feature. A wrong check made all the
broadcast packets coming from any client be dropped before delivery to the
interface.
Patch 2 instead fixes a "real" race condition in the TranslationTable code.

Please, tell me if there is any problem.
Thank you,
	Antonio



The following changes since commit a18e08bdcf845efb7344cea146e683df746bbfb4:

  net: sh_eth: fix the condition to fix the cur_tx/dirty_rx (2012-06-22 21:50:37 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git batman-adv/maint

for you to fetch changes up to 8b8e4bc0391f8abbcdb9e1c54415bcc0f4f5a2a0:

  batman-adv: fix race condition in TT full-table replacement (2012-06-23 17:21:35 +0200)

----------------------------------------------------------------
Included changes:
- fix for the AP-isolation feature
- fix for a race condition in the TranslationTable code

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: fix race condition in TT full-table replacement

Marek Lindner (1):
      batman-adv: only drop packets of known wifi clients

 net/batman-adv/translation-table.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)
