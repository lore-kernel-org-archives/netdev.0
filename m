From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH 0/2] ppp: add netlink support
Date: Wed, 23 Dec 2015 21:04:46 +0100
Message-ID: <cover.1450900138.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series adds netlink support for creating PPP devices.

It doesn't implement any PPP specific attribute beyond IFLA_PPP_DEV_FD,
which is necessary in the PPP device model for passing control plane
packets to user space.

Guillaume Nault (2):
  ppp: define reusable device creation functions
  ppp: implement rtnetlink device handling

 drivers/net/ppp/ppp_generic.c | 319 ++++++++++++++++++++++++++++++------------
 include/uapi/linux/if_link.h  |   8 ++
 2 files changed, 237 insertions(+), 90 deletions(-)

-- 
2.6.4

