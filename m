From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: [PATCH] net: add ETH_P_802_3_MIN
Date: Thu, 21 Mar 2013 11:02:55 -0300
Message-ID: <20130321110255.4c06b2b7@redhat.com>
References: <1363854568-32228-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org, Gross <jesse@nicira.com>,
	linux-media@vger.kernel.org, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	linux1394-devel@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>, Jesse
To: Simon Horman <horms@verge.net.au>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1363854568-32228-1-git-send-email-horms@verge.net.au>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Em Thu, 21 Mar 2013 17:29:28 +0900
Simon Horman <horms@verge.net.au> escreveu:

> Add a new constant ETH_P_802_3_MIN, the minimum ethernet type for
> an 802.3 frame. Frames with a lower value in the ethernet type field
> are Ethernet II.
> 
> Also update all the users of this value that I could find to use the
> new constant.
> 
> I anticipate adding some more users of this constant when
> adding MPLS support to Open vSwtich.
> 
> As suggested by Jesse Gross.
> 
> Compile tested only.
> 
> Cc: Jesse Gross <jesse@nicira.com>
> Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
> Cc: linux1394-devel@lists.sourceforge.net
> Cc: linux-media@vger.kernel.org
> Cc: dev@openvswitch.org
> Signed-off-by: Simon Horman <horms@verge.net.au>

...

> diff --git a/drivers/media/dvb-core/dvb_net.c b/drivers/media/dvb-core/dvb_net.c
> index 44225b1..9fc82a1 100644
> --- a/drivers/media/dvb-core/dvb_net.c
> +++ b/drivers/media/dvb-core/dvb_net.c
> @@ -185,7 +185,7 @@ static __be16 dvb_net_eth_type_trans(struct sk_buff *skb,
>  			skb->pkt_type=PACKET_MULTICAST;
>  	}
>  
> -	if (ntohs(eth->h_proto) >= 1536)
> +	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
>  		return eth->h_proto;

...

Acked-by: Mauro Carvalho Chehab <mchehab@redhat.com>

Cheers,
Mauro

------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_d2d_mar
