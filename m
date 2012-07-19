From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 18 Jul 2012 21:32:54 -0700 (PDT)
Message-ID: <20120718.213254.521778864761413612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok, we should be good to go now.

1) We have to statically initialize the init_net device list head
   rather than do so in an initcall, otherwise netprio_cgroup crashes
   if it's built statically rather than modular (Mark D. Rustad)

2) Fix SKB null oopser in CIPSO ipv4 option processing (Paul Moore)

3) Qlogic maintainers update (Anirban Chakraborty)

Please pull, thanks a lot.

The following changes since commit a018540141a931f5299a866907b27886916b4374:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-07-17 08:44:51 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 734b65417b24d6eea3e3d7457e1f11493890ee1d:

  net: Statically initialize init_net.dev_base_head (2012-07-18 13:32:27 -0700)

----------------------------------------------------------------
Anirban Chakraborty (1):
      MAINTAINERS: Changes in qlcnic and qlge maintainers list

Paul Moore (1):
      cipso: don't follow a NULL pointer when setsockopt() is called

Rustad, Mark D (1):
      net: Statically initialize init_net.dev_base_head

 MAINTAINERS              |    3 +--
 net/core/dev.c           |    3 ++-
 net/core/net_namespace.c |    4 +++-
 net/ipv4/cipso_ipv4.c    |    6 ++++--
 4 files changed, 10 insertions(+), 6 deletions(-)
