From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dwc_eth_qos: fix interrupt enable race
Date: Tue, 23 Aug 2016 17:12:41 -0700 (PDT)
Message-ID: <20160823.171241.1929468036153832657.davem@davemloft.net>
References: <1471962688-9226-1-git-send-email-larper@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        rabinv@axis.com, larper@axis.com
To: lars.persson@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471962688-9226-1-git-send-email-larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lars Persson <lars.persson@axis.com>
Date: Tue, 23 Aug 2016 16:31:28 +0200

> From: Rabin Vincent <rabinv@axis.com>
> 
> We currently enable interrupts before we enable NAPI. If an RX interrupt
> hits before we enabled NAPI then the NAPI callback is never called and
> we leave the hardware with RX interrupts disabled, which of course leads
> us to never handling received packets.  Fix this by moving the interrupt
> enable to after we've enable NAPI and the reclaim tasklet.
> 
> Fixes: cd5e41234729 ("dwc_eth_qos: do phy_start before resetting hardware")
> Signed-off-by: Rabin Vincent <rabinv@axis.com>
> Signed-off-by: Lars Persson <larper@axis.com>

Applied.
