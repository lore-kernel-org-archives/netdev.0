From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: add bond_tx_drop() helper
Date: Fri, 31 Oct 2014 20:25:24 +0100
Message-ID: <5453E224.2080101@redhat.com>
References: <1414781274.27538.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Mahesh Bandewar <maheshb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49388 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751708AbaJaTZk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2014 15:25:40 -0400
In-Reply-To: <1414781274.27538.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2014 07:47 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Because bonding stats are usually sum of slave stats, it was
> not easy to account for tx drops at bonding layer.
> 
> We can use dev->tx_dropped for this, as this counter is later
> added to the device stats (in dev_get_stats())
> 
> This extends the idea we had in commit ee6377147409a ("bonding: Simplify
> the xmit function for modes that use xmit_hash") for bond_3ad_xor_xmit()
> to other bonding modes.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_alb.c  |    2 +-
>  drivers/net/bonding/bond_main.c |   15 +++++++--------
>  drivers/net/bonding/bonding.h   |    6 ++++++
>  3 files changed, 14 insertions(+), 9 deletions(-)
> 

Nice,

Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
