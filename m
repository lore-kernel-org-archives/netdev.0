From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 0/6] netpoll: recursion fixes, queueing, and cleanups
Date: Thu, 17 Feb 2005 23:25:18 -0600
Message-ID: <1.378217222@selenic.com>
Cc: netdev@oss.sgi.com, Jeff Moyer <jmoyer@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch series against -rc4 fixes up some recursion deadlocks in
netpoll and adds support for fallback to queueing. Various cleanups
along the way.

Holds up under load testing via ipt_LOG on a dual Opteron with tg3.
