From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH 0/3] bridge: few enhancements and small fixes
Date: Wed, 12 Mar 2014 20:15:24 -0700
Message-ID: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	xen-devel@lists.xenproject.org, mcgrof@suse.com,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's a few fixes I've been carrying around. I've now tested them
on as many systems / environments as I can. They should be ready.

Luis R. Rodriguez (3):
  bridge: preserve random init MAC address
  bridge: trigger a bridge calculation upon port changes
  bridge: fix bridge root block on designated port

 net/bridge/br_device.c  |  1 +
 net/bridge/br_netlink.c | 24 ++++++++++++++++
 net/bridge/br_private.h |  2 ++
 net/bridge/br_stp.c     | 73 +++++++++++++++++++++++++++++++++++++++++++++----
 net/bridge/br_stp_if.c  |  6 +++-
 5 files changed, 99 insertions(+), 7 deletions(-)

-- 
1.8.5.3
