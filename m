From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: nps_enet: Disable interrupts before napi
 reschedule
Date: Sun, 29 May 2016 22:35:42 -0700 (PDT)
Message-ID: <20160529.223542.1386340561946869732.davem@davemloft.net>
References: <1464264006-26627-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: noamca@mellanox.com, linux-kernel@vger.kernel.org,
	abrodkin@synopsys.com, netdev@vger.kernel.org
To: eladkan@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464264006-26627-1-git-send-email-eladkan@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Elad Kanfi <eladkan@mellanox.com>
Date: Thu, 26 May 2016 15:00:06 +0300

> From: Elad Kanfi <eladkan@mellanox.com>
> 
> Since NAPI works by shutting down event interrupts when theres
> work and turning them on when theres none, the net driver must
> make sure that interrupts are disabled when it reschedules polling.
> By calling napi_reschedule, the driver switches to polling mode,
> therefor there should be no interrupt interference.
> Any received packets will be handled in nps_enet_poll by polling the HW
> indication of received packet until all packets are handled.
> 
> Signed-off-by: Elad Kanfi <eladkan@mellanox.com>
> Acked-by: Noam Camus <noamca@mellanox.com>

Applied.
