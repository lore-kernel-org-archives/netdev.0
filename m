From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH 1/1] atl1c: fix issue of transmit queue 0 timed out
Date: Tue, 26 Jun 2012 11:03:11 -0700
Message-ID: <20120626180311.GC5070@tux>
References: <1340724786-3819-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <qca-linux-team@qualcomm.com>,
	<nic-devel@qualcomm.com>, xiong <xiong@qca.qualcomm.com>
To: "Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1340724786-3819-1-git-send-email-cjren@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 26, 2012 at 12:33:06PM -0300, Ren, Cloud wrote:
> From: xiong <xiong@qca.qualcomm.com>
> 
> some people report atl1c could cause system hang with following
> kernel trace info:
> ---------------------------------------
> WARNING: at.../net/sched/sch_generic.c:258
> dev_watchdog+0x1db/0x1d0()
> ...
> NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
> ...
> ---------------------------------------
> This is caused by netif_stop_queue calling when cable Link is down
> but netif_wake_queue isn't called when cable Link is resume.
> 
> Signed-off-by: xiong <xiong@qca.qualcomm.com>
> Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>

If this fixes  a system hang then this could be a stable
fix -- that is, this should be propagated to older stable
kernels, no?

If so then please add to the commit log a line like this:

Cc: stable@vger.kernel.org [3.4]

Note: this is for the commit log! Right above the line below
that has "---"

  Luis
