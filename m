From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 0/7] netpoll: recursion fixes, queueing, and cleanups
Date: Thu, 03 Mar 2005 14:46:31 -0600
Message-ID: <1.454130102@selenic.com>
Cc: netdev@oss.sgi.com, Jeff Moyer <jmoyer@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch series against 2.6.11 fixes up some recursion deadlocks in
netpoll and adds support for fallback to queueing. Various cleanups
along the way.

Holds up under load testing via ipt_LOG on a dual Opteron with tg3.
Please apply.
