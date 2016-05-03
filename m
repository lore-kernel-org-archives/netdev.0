From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: fix igmp / mld query parsing
Date: Tue, 3 May 2016 13:26:23 -0700
Message-ID: <20160503132623.59cf54fb@xeon-e3>
References: <1462306734-4183-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Simon Wunderlich <sw@simonwunderlich.de>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	"David S . Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: Linus =?UTF-8?B?TMO8c3Npbmc=?= <linus.luessing@c0d3.blue>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1462306734-4183-1-git-send-email-linus.luessing@c0d3.blue>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue,  3 May 2016 22:18:54 +0200
Linus L=C3=BCssing <linus.luessing@c0d3.blue> wrote:

> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 03661d9..7105cdf 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1271,6 +1271,7 @@ static int br_ip4_multicast_query(struct net_bridge=
 *br,
>  	unsigned long max_delay;
>  	unsigned long now =3D jiffies;
>  	__be32 group;
> +	int offset =3D skb_transport_offset(skb);
shouldn't this be unsigned?
