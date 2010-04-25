From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 25 Apr 2010 15:12:56 -0700 (PDT)
Message-ID: <20100425.151256.159623106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The TCP bind conflict port allocation fix had a bug on the ipv6 side,
hit by a bunch of folks.  Fix from Eric Dumazet.

An e100 crash fix from Alan Cox that should cure a bunch of hits we've
got on kerneloops.org, no mutual exclusion done by the TX timeout
workqueue causes crashes as two threads of control try to reset the
chip in parallel.

Please pull, thanks a lot!

The following changes since commit ddc9b34c3b3bc063a7d9eb891ae09b8f49cfb27e:
  Linus Torvalds (1):
        Merge branch 'fixes' of git://git.kernel.org/.../davej/cpufreq

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alan Cox (1):
      e100: Fix the TX workqueue race

Eric Dumazet (1):
      ipv6: Fix inet6_csk_bind_conflict()

 drivers/net/e100.c               |   10 ++++++++--
 net/ipv6/inet6_connection_sock.c |    2 +-
 2 files changed, 9 insertions(+), 3 deletions(-)
