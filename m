From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH V2 00/11] net: mediatek: various small fixes
Date: Fri, 10 Jun 2016 13:30:15 +0200
Message-ID: <ac8eae20-f8a5-6e06-43fd-c2826599b709@phrozen.org>
References: <1465558088-15265-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Sean Wang <keyhaede@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
	Felix Fietkau <nbd@nbd.name>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465558088-15265-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 10/06/2016 13:27, John Crispin wrote:
> This series contains various small fixes that we stumbled across while
> doing thorough testing and code level reviewing of the driver. The only
> patch that sticks out is the first one, which addresses a DQL related
> issue. The rest are just minor fixes.
> 

Hi David,

i forgot to remove the last sentence here. can you live with that as it
wont end up in the git history or do you want me to send a V3 with this
line removed.

	John


> Changes in V2:
> * drop the DQL patch from the list until a better solution is found
> 
> John Crispin (11):
>   net: mediatek: add missing return code check
>   net: mediatek: fix missing free of scratch memory
>   net: mediatek: invalid buffer lookup in mtk_tx_map()
>   net: mediatek: dropped rx packets are not being counted properly
>   net: mediatek: add next data pointer coherency protection
>   net: mediatek: disable all interrupts during probe
>   net: mediatek: fix threshold value
>   net: mediatek: increase watchdog_timeo
>   net: mediatek: fix off by one in the TX ring allocation
>   net: mediatek: only wake the queue if it is stopped
>   net: mediatek: remove superfluous queue wake up call
> 
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c |   61 ++++++++++++++++++---------
>  drivers/net/ethernet/mediatek/mtk_eth_soc.h |    3 ++
>  2 files changed, 45 insertions(+), 19 deletions(-)
> 
