From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 05/13] remove last_rx update from loopback device
Date: Tue, 15 Mar 2005 15:08:09 -0800
Message-ID: <20050315150809.579c5e85.akpm@osdl.org>
References: <200503152222.j2FMMbhG016805@shell0.pdx.osdl.net>
	<423764A3.8030201@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, christoph@graphe.net,
        nirajk@calsoftinc.com, christoph@lameter.com, Shai@Scalex86.org
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <423764A3.8030201@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>
> > -	dev->last_rx = jiffies;
> > -
> >  	lb_stats = &per_cpu(loopback_stats, get_cpu());
> >  	lb_stats->rx_bytes += skb->len;
> >  	lb_stats->tx_bytes += skb->len;
> 
> I disagree.  loopback.c is doing precisely what it should be doing.

Nothing actually seems to use last_rx?
