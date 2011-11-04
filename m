From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net v2 0/8] forcedeth: minor fixes for stats, rmmod, sparse
Date: Thu,  3 Nov 2011 18:41:15 -0700
Message-ID: <cover.1320369398.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is the v2 of a forcedeth patch series I sent a few months
ago (... May).

Changes since v1:
 - rebased on top of netdev tip
 - do not repeat name of device in netdev_dbg
 - do not completely mute TX timeout messages when debug_tx_timeout is
   not set
 - make debug_tx_timeout writable in /sys/module

I am re-submitting "expose module parameters in /sys/module" as it can
be useful in production and I was assured it doesn't add much memory
overhead by the sysfs maintainers.

Tested:
  16-way x86_64 SMP, dual forcedeth


############################################
# Patch Set Summary:

David Decotigny (2):
  forcedeth: expose module parameters in /sys/module
  forcedeth: fix a few sparse warnings (variable shadowing)

Mandeep Baines (1):
  forcedeth: Improve stats counters

Mike Ditto (2):
  forcedeth: Acknowledge only interrupts that are being processed
  forcedeth: Add messages to indicate using MSI or MSI-X

Salman Qazi (1):
  forcedeth: Fix a race during rmmod of forcedeth

Sameer Nanda (2):
  forcedeth: new ethtool stat "tx_timeout" to account for tx_timeouts
  forcedeth: allow to silence tx_timeout debug messages

 drivers/net/ethernet/nvidia/forcedeth.c |  182 +++++++++++++++++++------------
 1 files changed, 110 insertions(+), 72 deletions(-)

-- 
1.7.3.1
