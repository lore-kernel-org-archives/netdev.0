From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1]net:ethernet:fixed a coding style issue relating
 space.
Date: Fri, 18 May 2012 14:56:17 -0700
Message-ID: <20120518145617.710bc1d6@nehalam.linuxnetplumber.net>
References: <1337377537-4636-1-git-send-email-ahiliation@yahoo.co.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeffrin Jose <ahiliation@yahoo.co.in>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337377537-4636-1-git-send-email-ahiliation@yahoo.co.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 19 May 2012 03:15:37 +0530
Jeffrin Jose <ahiliation@yahoo.co.in> wrote:

> Fixed a coding style issue relating to  space found
> by checkpatch.pl tool in net/ethernet/eth.c
> 
> Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
> ---
>  net/ethernet/eth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 36e5880..c847aa6 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -178,7 +178,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
>  	 *      seems to set IFF_PROMISC.
>  	 */
>  
> -	else if (1 /*dev->flags&IFF_PROMISC */ ) {
> +	else if (1 /*dev->flags&IFF_PROMISC */) {
>  		if (unlikely(!ether_addr_equal_64bits(eth->h_dest,
>  						      dev->dev_addr)))
>  			skb->pkt_type = PACKET_OTHERHOST;

Rather than put lips on a pig, why not remove the bogus if?
