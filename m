From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH] [trivial]doc:net: Fix typo in Documentation/networking
Date: Wed, 30 Oct 2013 11:22:31 -0700
Message-ID: <52714E67.50902@infradead.org>
References: <1383119175-1963-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Masanari Iida <standby24x7@gmail.com>, trivial@kernel.org,
	linux-kenrel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:51205 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab3J3SWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 14:22:34 -0400
In-Reply-To: <1383119175-1963-1-git-send-email-standby24x7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/13 00:46, Masanari Iida wrote:
> Correct spelling typo in Documentation/networking
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>
> ---
>  Documentation/networking/dccp.txt         | 4 ++--
>  Documentation/networking/e100.txt         | 2 +-
>  Documentation/networking/ieee802154.txt   | 4 ++--
>  Documentation/networking/l2tp.txt         | 2 +-
>  Documentation/networking/netdev-FAQ.txt   | 2 +-
>  Documentation/networking/netlink_mmap.txt | 6 +++---
>  Documentation/networking/operstates.txt   | 2 +-
>  Documentation/networking/rxrpc.txt        | 2 +-
>  Documentation/networking/stmmac.txt       | 8 ++++----
>  Documentation/networking/vortex.txt       | 4 ++--
>  Documentation/networking/x25-iface.txt    | 2 +-
>  11 files changed, 19 insertions(+), 19 deletions(-)

> diff --git a/Documentation/networking/ieee802154.txt b/Documentation/networking/ieee802154.txt
> index 09eb573..98c8b2b 100644
> --- a/Documentation/networking/ieee802154.txt
> +++ b/Documentation/networking/ieee802154.txt
> @@ -66,7 +66,7 @@ net_device, with .type = ARPHRD_IEEE802154. Data is exchanged with socket family
>  code via plain sk_buffs. On skb reception skb->cb must contain additional
>  info as described in the struct ieee802154_mac_cb. During packet transmission
>  the skb->cb is used to provide additional data to device's header_ops->create
> -function. Be aware, that this data can be overriden later (when socket code
> +function. Be aware, that this data can be overridden later (when socket code

fwiw, I would drop the comma above...

>  submits skb to qdisc), so if you need something from that cb later, you should
>  store info in the skb->data on your own.
>  
> diff --git a/Documentation/networking/operstates.txt b/Documentation/networking/operstates.txt
> index 9769457..c40f4bb 100644
> --- a/Documentation/networking/operstates.txt
> +++ b/Documentation/networking/operstates.txt
> @@ -89,7 +89,7 @@ packets. The name 'carrier' and the inversion are historical, think of
>  it as lower layer.
>  
>  Note that for certain kind of soft-devices, which are not managing any
> -real hardware, there is possible to set this bit from userpsace.
> +real hardware, there is possible to set this bit from userspace.

                  it is possible

>  One should use TVL IFLA_CARRIER to do so.
>  
>  netif_carrier_ok() can be used to query that bit.

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.


-- 
~Randy
