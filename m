From: "David S. Miller" <davem@redhat.com>
Subject: Re: BUG in tcp_timer.c:tcp_retransmit_timer()
Date: Mon, 29 Mar 2004 21:50:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329215057.3fd40210.davem@redhat.com>
References: <20040329200954.7baac255.davem@redhat.com>
	<Pine.LNX.4.44.0403292251520.27795-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Tomar, Nagendra" <nagendra_tomar@adaptec.com>
In-Reply-To: <Pine.LNX.4.44.0403292251520.27795-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Mar 2004 22:54:14 +0530 (IST)
Nagendra Singh Tomar <nagendra_tomar@adaptec.com> wrote:

> 	Thats right. But what about the other cases of retransmission 
> failures for which we are having a negative return (-ENOMEM, -EAGAIN, 
> -EHOSTUNREACH etc). Even for these cases its not a good idea to 
> artificially increment tp->retransmits, lest in some extreme case we might 
> timeout a connection without a single packet going on the wire.

That's just like the packet getting dropped at the next hop,
and not the case this branch of code intends to deal with.
