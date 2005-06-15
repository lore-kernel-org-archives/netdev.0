From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: Re: [-mm PATCH] signed vs unsigned cleanup in net/ipv4/raw.c
Date: Wed, 15 Jun 2005 21:28:23 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0506152127150.3842@dragon.hyggekrogen.localhost>
References: <Pine.LNX.4.62.0506152101350.3842@dragon.hyggekrogen.localhost>
 <20050615.121628.112622743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: juhl-lkml@dif.dk, yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru,
        jmorris@redhat.com, waltje@uWalt.NL.Mugnet.ORG.sgi.com,
        ross.biro@gmail.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050615.121628.112622743.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Jun 2005, David S. Miller wrote:

> 
> I'm not merging this thing, at least no all at once.
> 
> "size_t" vs. "unsigned int" vs. "int" length comparisons are where all
> the security problems come from in the protocol stack
> 
> Therefore you should make a seperate patch for each type
> change you make and explain why it doesn't add some regression
> in terms of signedness issues.
> 

Fair enough, I'll split it into little bits and submit them one by one 
with explanations. Not a problem at all.

-- 
Jesper Juhl
