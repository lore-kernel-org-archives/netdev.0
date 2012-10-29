From: Rob Herring <rob.herring@calxeda.com>
Subject: Re: [PATCH 0/6] Calxeda xgmac performance fixes
Date: Mon, 29 Oct 2012 12:52:39 -0500
Message-ID: <508EC267.6020208@calxeda.com>
References: <1350054908-30646-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jonathan@jonmasters.org, eric.dumazet@gmail.com,
	Mark Langsdorf <mark.langsdorf@calxeda.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350054908-30646-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

On 10/12/2012 10:15 AM, Rob Herring wrote:
> From: Rob Herring <rob.herring@calxeda.com>
> 
> This is a series of performance improvements to the xgmac driver. The most
> significant changes are the alignment fixes to avoid alignment traps on
> received frames and using relaxed i/o accessors.

Can you please apply this series for 3.7. They are all self-contained to
the xgmac driver and fix some performance issues including unaligned
access traps in the IP stack. If 3.7 is not acceptable, then 3.8 is fine.

Note that only patch 5 has a v2 version.

Rob

> 
> Rob Herring (6):
>   net: calxedaxgmac: enable operate on 2nd frame mode
>   net: calxedaxgmac: remove explicit rx dma buffer polling
>   net: calxedaxgmac: use relaxed i/o accessors in rx and tx paths
>   net: calxedaxgmac: drop some unnecessary register writes
>   net: calxedaxgmac: rework transmit ring handling
>   net: calxedaxgmac: ip align receive buffers
> 
>  drivers/net/ethernet/calxeda/Kconfig |    2 +-
>  drivers/net/ethernet/calxeda/xgmac.c |   57 +++++++++++++++-------------------
>  2 files changed, 26 insertions(+), 33 deletions(-)
> 
