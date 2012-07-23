From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH 0/1] sched: Add a new API to find the prefer idlest cpu
Date: Sun, 22 Jul 2012 23:57:14 -0700
Message-ID: <1343026634.13461.15.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, vivek@us.ibm.com,
	sri@us.ibm.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce a new API to choose per-cpu thread from cgroup control cpuset
(allowed) and preferred cpuset (local numa-node).

The receiving cpus of a networking device are not under cgroup controls.
When such a networking device uses per-cpu thread model, the cpu which
is chose to process the packets might not be part of cgroup cpusets
without this API. On numa system, the preferred cpusets would help to
reduce expensive cross memory access to/from the other node.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 include/linux/sched.h |    2 ++
 kernel/sched/fair.c   |   30 ++++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+), 0 deletions(-)

Thanks
Shirley
