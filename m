From: Anton Blanchard <anton@samba.org>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Fri, 14 Jan 2005 12:25:04 +1100
Message-ID: <20050114012504.GF6309@krispykreme.ozlabs.ibm.com>
References: <20050113171234.3fde0925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050113171234.3fde0925.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi Dave,
 
> Anton, can you and the other IBM folks who can reproduce
> the problem give this test patch a whirl?
> 
> Herbert and I aren't exactly sure what the exact sequence
> of events is that causes the problem, but we do know that
> this code is highly suspect.
> 
> [ BTW, Herbert, it just occurred to me that these adjustments
>   are incorrect for the skb->data pulling case since we really
>   aren't liberating the data. ]

Excellent! Ive forwarded it on, lets see if it reproduces.

Anton
