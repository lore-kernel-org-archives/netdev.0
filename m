From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: 2.6.9-rc1+bk: assertion tcp_get_pcount failed at net/ipv4/tcp_input.c
Date: Thu, 09 Sep 2004 23:39:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41414C3D.2090606@us.ibm.com>
References: <20040909111233.GA3987@steel.home>	<20040910033055.GA26790@gondor.apana.org.au> <20040909222542.7a30c0e4.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, fork0@users.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040909222542.7a30c0e4.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> Herbert did you see my division fix I made today for
> tso_factor calculation?  I was dividing by the TSO mss
> instead of the normal one :-)

Dave, I'm just catching up with the most recent
kernel (from 2.6.8.1 and a hiatus), and I believe
the fixes you refer to as well as the change in
tcp_init_cwnd (tso_factor etc) make TSO consistent
with the standard now.

That correct? (And thanks, much appreciated, I was
about to fiddle with the same stuff :)).

thanks,
Nivedita
