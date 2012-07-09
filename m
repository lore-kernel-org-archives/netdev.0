From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] atl1c: fix issue of transmit queue 0 timed out
Date: Mon, 09 Jul 2012 00:00:23 -0700 (PDT)
Message-ID: <20120709.000023.862144144755024401.davem@davemloft.net>
References: <1341370308-23233-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com
To: cjren@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341370308-23233-1-git-send-email-cjren@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <cjren@qca.qualcomm.com>
Date: Wed, 4 Jul 2012 10:51:48 +0800

> some people report atl1c could cause system hang with following
> kernel trace info:
> ---------------------------------------
> WARNING: at.../net/sched/sch_generic.c:258 dev_watchdog+0x1db/0x1d0()
> ...
> NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
> ...
> ---------------------------------------
> This is caused by netif_stop_queue calling when cable Link is down.
> So remove netif_stop_queue, because link_watch will take it over.
> 
> Signed-off-by: xiong <xiong@qca.qualcomm.com>
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>

Applied, thanks.
