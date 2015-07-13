From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/2] Fix long-standing regression in ser_gigaset ISDN driver
Date: Tue, 14 Jul 2015 00:37:13 +0200 (CEST)
Message-ID: <cover.1436826434.git.tilman@imap.cc>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>, linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes a serious regression in the Gigaset M101 driver
introduced in kernel release 3.10 and removes some unneeded code.

Please also queue up patch 1 of the series for inclusion in the
stable/longterm releases 3.10 and later.

Tilman Schmidt (2):
  isdn/gigaset: reset tty->receive_room when attaching ser_gigaset
  isdn/gigaset: drop unused ldisc methods

 drivers/isdn/gigaset/ser-gigaset.c |   35 ++++++++++-------------------------
 1 files changed, 10 insertions(+), 25 deletions(-)
