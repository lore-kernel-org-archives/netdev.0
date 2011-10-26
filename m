From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 25 Oct 2011 20:32:20 -0400 (EDT)
Message-ID: <20111025.203220.473592143736213946.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Three bug fixes here, including the sk_clone() error path unlock
fix from Thomas Gleixner.

As for the wireless warning spew, it is my understanding that person
most able to fix that bug is in the same room with you right now (hi
Johannes Berg :-)

Please pull, thanks a lot!

The following changes since commit 7670c7010c7b367ca40c3aba02afb3614976=
4a6e:

  Merge branch 'for-linus' of git://github.com/gregungerer/m68knommu (2=
011-10-25 16:25:48 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

David Woodhouse (1):
      caif: Fix BUG() with network namespaces

Maciej =AFenczykowski (1):
      net: make bonding slaves honour master's skb->priority

Thomas Gleixner (1):
      net: Unlock sock before calling sk_free()

 drivers/net/bonding/bond_main.c |    1 -
 net/caif/caif_dev.c             |    5 +++--
 net/core/sock.c                 |    1 +
 3 files changed, 4 insertions(+), 3 deletions(-)
