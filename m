From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: simple change to qdisc_restart()
Date: Tue, 20 May 2003 08:33:50 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520083020.N40924@shell.cyberus.ca>
References: <20030520082217.GC978@udine> <20030520.012824.85398613.davem@redhat.com>
 <20030520085724.GD978@udine> <16074.1339.3673.938923@robur.slu.se>
 <20030520112109.GE978@udine> <16074.7787.988583.56689@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Lemoine <Eric.Lemoine@Sun.COM>, "David S. Miller" <davem@redhat.com>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16074.7787.988583.56689@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 20 May 2003, Robert Olsson wrote:

>
>  Sounds interesting...
>  So reordering should be guaranteed within "connections" but not per interface.
>
>  And if you can repeat the trick with per-cpu rings for tx you can eventually
>  eliminate cache bouncing when sending/freeing skb's.
>
>  We tried to tag with cpu-owner in tx-ring when doing hard_xmit and having same
>  cpu sending it to do kfree but the complexity balanced the win... The thinking
>  was that per-cpu tx rings could help.
>

His patch should be interesting. I have seen NICs showing up in the market
with multiple DMA rings/channels and you can map flows to channels.
Locking the device on egress just because one of the rings is full doesnt
make sense. Such boards maybe the perfect pktgen board for you, btw ;->
Can you post your patch Eric?

cheers,
jamal
