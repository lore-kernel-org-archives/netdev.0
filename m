From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Reducing the overhead on the network core
Date: Mon, 28 Mar 2005 17:14:36 -0800
Message-ID: <20050328171436.62a0b80b.davem@davemloft.net>
References: <200503282144.08870.vicente.feito@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vicente Feito <vicente.feito@gmail.com>
In-Reply-To: <200503282144.08870.vicente.feito@gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


We already do this and set the skb->packet_type field to
PACKET_HOST, PACKET_BROADCAST, PACKET_MULTICAST etc.
And the input paths test these values.

We still have to pass the packet into netif_rx() to deal
with network taps that want to see packets that are not
destined for us in any way.
