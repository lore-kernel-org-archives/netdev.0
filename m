From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix loopback over bridge port
Date: Mon, 29 Dec 2003 17:43:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031229174320.283fd28c.davem@redhat.com>
References: <200312271536.46940.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200312271536.46940.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 27 Dec 2003 15:36:46 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> The patch below fixes this by adding a check in __handle_bridge().
> It also changes br_netfilter.c by only doing the paranoid checks of
> br_nf_post_routing() when CONFIG_NETFILTER_DEBUG is set. I think the
> loopback fix will get rid of any skbuffs matching those paranoid checks.
> 
> The patch also introduces/removes some whitespace in br_netfilter.c.

Both 2.4.x and 2.6.x variants applied, thanks Bart.

> I think the code (in net/ipv4/ip_output.c::ip_dev_loopback_xmit())
> __skb_pull(newskb, newskb->nh.raw - newskb->data);
> is useless, as data always points to the network header at that moment. But
> that's not really my territory...

I'll look into this, it might be needed for proper packet sniffer
handling but that's just an offhand guess...
