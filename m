From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [NETLINK] Do not netlink_unicast shared packet in kernel/audit.c
Date: Sun, 16 Jan 2005 09:34:59 +0100
Message-ID: <41EA2733.1010308@tpack.net>
References: <E1Cpo1q-0007lI-00@gondolin.me.apana.org.au> <41E942AF.3030202@tpack.net> <20050115183023.GA31211@gondor.apana.org.au> <41E97B1A.30205@tpack.net> <20050116080254.GA2997@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: simon.roscic@chello.at, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050116080254.GA2997@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> I'm hesitant to put an outright ban on it since it will force callers
> such as kernel/audit.c to always do an skb_clone.
> 
> So here is a patch to handle shared skb's by cloning them if we're
> going to do a pskb_expand_head.  This patch depends on the previous
> one that moves skb_orphan into netlink_trim.

Very nice, Herbert. This should be fine for everybody.

-Tommy
