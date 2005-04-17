From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netem: account for packets in delayed queue in qlen
Date: Sun, 17 Apr 2005 17:38:40 +0200
Message-ID: <42628300.9010007@trash.net>
References: <20050329152110.38d50653@dxpl.pdx.osdl.net>	<4252EB9D.9070305@trash.net> <20050407120417.4297cd14@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050407120417.4297cd14@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Would this work better.? It just increases qlen by +/- 1 on enqueue, dequeue.
> It also allows < 1ms delays if there is enough traffic going through.

It looks better, but with duplication there can still be an increment
of 2 in netem_enqueue().

Regards
Patrick
