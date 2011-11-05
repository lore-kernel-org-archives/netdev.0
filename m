From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net v4 0/4] forcedeth: minor fixes for stats, rmmod, sparse
Date: Fri,  4 Nov 2011 21:04:38 -0700
Message-ID: <cover.1320463771.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:55050 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385Ab1KEEFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2011 00:05:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Thanks for your feedback. Here is v4, with only the (minor) bug fixes
for net. I am setting the "new features" patches aside for later
(net-next).

Since I am still very much of a newbie with the way net & net-next
work, could you please redirect me to some pointer on how/when the
schedule works?

Regards,

Tested: 16-way x86_64 + forcedeth

Changes since v3:
 - removed feature additions, this leaves minor sparse and stats
   fixes. Feature additions shipped previously will go to net-next

Changes since v2:
 - removed "Fix a race during rmmod of forcedeth" from the series
   (will look at it separately with original author)
 - added "remove unneeded stats updates" and "64-bit stats"
 - reordered patches

Changes since v1:
 - rebased on top of netdev tip
 - do not repeat name of device in netdev_dbg
 - do not completely mute TX timeout messages when debug_tx_timeout is
   not set
 - make debug_tx_timeout writable in /sys/module
 Note: I am re-submitting "expose module parameters in /sys/module" as
       it can be useful in production and I was assured it doesn't add
       much memory overhead by the sysfs maintainers.

Tested:
  16-way x86_64 SMP, dual forcedeth ->
  RX bytes:7244556582 (7.2 GB)  TX bytes:181904254 (181.9 MB)


############################################
# Patch Set Summary:

David Decotigny (2):
  forcedeth: remove unneeded stats updates
  forcedeth: fix a few sparse warnings (variable shadowing)

Mandeep Baines (1):
  forcedeth: Improve stats counters

Mike Ditto (1):
  forcedeth: Acknowledge only interrupts that are being processed

 drivers/net/ethernet/nvidia/forcedeth.c |   86 +++++++++++--------------------
 1 files changed, 30 insertions(+), 56 deletions(-)

-- 
1.7.3.1
