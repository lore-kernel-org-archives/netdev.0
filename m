From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 23:45:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41590898.3060900@us.ibm.com>
References: <20040923161141.4ea9be4c.davem@davemloft.net>	<Pine.NEB.4.33.0409271416360.14606-100000@dexter.psc.edu>	<20040927160411.22b44f48.davem@davemloft.net>	<20040927233639.GA8333@gondor.apana.org.au>	<20040927171356.6a59d039.davem@davemloft.net>	<20040928003412.GA8755@gondor.apana.org.au> <20040927215901.6f65dc15.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, jheffner@psc.edu, ak@suse.de,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040927215901.6f65dc15.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> It's got a nasty bug though, I'm not updating
> TCP_SKB_CB(skb)->seq so retransmits have corrupted
> sequence numbers, doh!  And hey if I update that
> then I do not need this tso_offset thingy.

Hmm, I got sidetracked by seeing corrupted sequence
numbers in my tcpdump traces from before, although
that shouldn't have been the case..(sorry, don't
have access to boxes at the moment, will post it
tmrw). Was seeing the sequence numbers go backwards
(simple scp testing, bk10)..

Will redo testing in the morning on latest patches...

thanks,
Nivedita
