From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 00:20:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415910D2.7010808@us.ibm.com>
References: <20040923161141.4ea9be4c.davem@davemloft.net>	<Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>	<20040927160411.22b44f48.davem@davemloft.net>	<20040927233639.GA8333@gondor.apana.org.au> <20040927171356.6a59d039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, jheffner@psc.edu, ak@suse.de,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040927171356.6a59d039.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> Bright minds think alike.  :-)  We have to keep all the other
> packet counts in sync as well.
> 
> Andi, others, forget my previous hack patch to tcp_clean_rtx_queue()
> and give this more complete patch a try.
> 
> I'm getting really good results here on my tg3<-->tg3 setup using
> this patch.

Dave, were you seeing a significant number of retransmissions
and sacks in your tests?

thanks,
Nivedita
