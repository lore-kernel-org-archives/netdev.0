From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 0/8] netpoll: various bugfixes
Date: Thu, 11 Aug 2005 21:18:28 -0500
Message-ID: <1.502409567@selenic.com>
Cc: ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.com>, "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch series cleans up a few outstanding bugs in netpoll:

- two bugfixes from Jeff Moyer's netpoll bonding
- a tweak to e1000's netpoll stub
- timeout handling for e1000 with carrier loss
- prefilling SKBs at init
- a fix-up for a race discovered in initialization
- an unused variable warning

This patch set was tested over repeated rebooting with both tg3 and
e1000 and random cable disconnection, with and without SMP and
preempt. Please apply.
