From: Ed Cashin <ecashin@coraid.com>
Subject: [PATCH 0/2] do not disable sg when packet requires no checksum
Date: Wed, 19 Sep 2012 18:16:57 -0700
Message-ID: <cover.1348088283.git.ecashin@coraid.com>
References: <1348079358.4585@cat.he.net>
       <1348084504.2636.41.camel@bwh-desktop.uk.solarflarecom.com>
Cc: ecashin@coraid.com, akpm@linux-foundation.org,
	bhutchings@solarflare.com, jesse@nicira.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348084504.2636.41.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This two-part patchset replaces an earlier net-only patch that
added an explicit check for the AoE protocol to harmonize_features
in net/core/dev.c.

Following the suggestion of Ben Hutchings, this patchset makes
the decision in the network layer protocol agnostic instead of
using ETH_P_AOE as a special case.

Ed L. Cashin (2):
  aoe: mark AoE packets as requiring no checksumming
  net: do not disable sg for packets requiring no checksum

 drivers/block/aoe/aoecmd.c |    1 +
 net/core/dev.c             |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

-- 
1.7.2.5
