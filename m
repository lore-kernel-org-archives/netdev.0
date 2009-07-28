From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 0/1] mISDN: Fix handling of receive buffer size in L1oIP
Date: Tue, 28 Jul 2009 13:37:01 +0200
Message-ID: <cover.1248781021.git.keil@b1-systems.de>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de,
	Andreas Eversberg <andreas@eversberg.eu>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753413AbZG1Lu1@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix a regression introduced in 2.6.31 with the commit
8c90e11e3543d7de612194a042a148caeaab5f1d "mISDN: Use kernel_{send,recv}msg instead of open coding".

Linus: you can pull the fix from
git://git.kernel.org/pub/scm/linux/kernel/git/kkeil/ISDN-2.6-net-next for_linus

David for net-next-2.6 you can get it from:
git://git.kernel.org/pub/scm/linux/kernel/git/kkeil/ISDN-2.6-net-next for_david

Andreas Eversberg (1):
  mISDN: Fix handling of receive buffer size in L1oIP

 drivers/isdn/mISDN/l1oip_core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)
