From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sat, 12 Dec 2009 03:29:38 -0800 (PST)
Message-ID: <20091212.032938.136002802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762092AbZLLL3d@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm doing a quick push to fix the Kaweth USB driver build
failure.  It's due to a miscommunication between Greg KH
and myself, and we'll make sure this doesn't happen again.

There's also two Intel gigabit fixes from Alexander Duyck and
a be2net driver fix from Ajit Khaparde.

Please pull, thanks a lot!

The following changes since commit 053fe57ac249a9531c396175778160d9e9509399:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../davem/net-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      be2net: fix error in rx completion processing.

Alexander Duyck (2):
      igb: fix handling of mailbox collisions between PF/VF
      igbvf: avoid reset storms due to mailbox issues

Oliver Neukum (1):
      usb: remove rare pm primitive for conversion to new API

 drivers/net/benet/be_main.c |    4 ++--
 drivers/net/igb/igb_main.c  |   22 +++++++++++++---------
 drivers/net/igbvf/igbvf.h   |    1 +
 drivers/net/igbvf/netdev.c  |    8 +++++++-
 drivers/net/usb/kaweth.c    |    4 ++--
 5 files changed, 25 insertions(+), 14 deletions(-)
