From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netem: account for packets in delayed queue in qlen
Date: Tue, 19 Apr 2005 11:06:39 +1000
Message-ID: <20050419110639.47767113@localhost.localdomain>
References: <20050329152110.38d50653@dxpl.pdx.osdl.net>
	<4252EB9D.9070305@trash.net>
	<20050407120417.4297cd14@dxpl.pdx.osdl.net>
	<42628300.9010007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42628300.9010007@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 17 Apr 2005 17:38:40 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Would this work better.? It just increases qlen by +/- 1 on enqueue, dequeue.
> > It also allows < 1ms delays if there is enough traffic going through.
> 
> It looks better, but with duplication there can still be an increment
> of 2 in netem_enqueue().

There may be no sane way to do duplication without that. Other ways like injecting
packets again at top of queue with a thread/tasklet seem rather gross
