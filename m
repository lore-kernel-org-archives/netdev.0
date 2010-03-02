From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 02 Mar 2010 04:03:16 -0800 (PST)
Message-ID: <20100302.040316.155442888.davem@davemloft.net>
References: <20100228.230535.123985162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100228.230535.123985162.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sun, 28 Feb 2010 23:05:35 -0800 (PST)

> Please pull, thanks a lot!
> 
> The following changes since commit 30ff056c42c665b9ea535d8515890857ae382540:
>   Linus Torvalds (1):
>         Merge branch 'x86-uv-for-linus' of git://git.kernel.org/.../tip/linux-2.6-tip
> 
> are available in the git repository at:
> 
>   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git master

Linus, if you haven't pulled in the networking tree yet, please pull
again as I just pushed the following bug fixes into there tonight.

Thanks!

The following changes since commit 47871889c601d8199c51a4086f77eebd77c29b0b:
  David S. Miller (1):
        Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git master

Eric Dumazet (1):
      net: fix protocol sk_buff field

Herton Ronaldo Krzesinski (1):
      sis190: fix cable detect via link status poll

Jiri Pirko (1):
      virtio_net: remove forgotten assignment

Sathya Perla (1):
      be2net: fix tx completion polling

Sridhar Samudrala (1):
      bridge: Fix build error when IGMP_SNOOPING is not enabled

 drivers/net/benet/be_cmds.c |   26 +++++++++++-----------
 drivers/net/benet/be_cmds.h |    2 +-
 drivers/net/benet/be_main.c |   47 +++++++++++++++++++++----------------------
 drivers/net/sis190.c        |   23 ++++++++++++++++----
 drivers/net/virtio_net.c    |    1 -
 include/linux/skbuff.h      |    2 +-
 net/bridge/br_private.h     |   14 ++++++++----
 7 files changed, 65 insertions(+), 50 deletions(-)
