From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH] Avoid gettimeofday when not needed
Date: Wed, 31 Mar 2004 17:24:47 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403311705460.19615@rhea.tcs.hut.fi>
References: <200403311201.i2VC13D19579@zero.aec.at>
 <Pine.LNX.4.58.0403311552070.19615@rhea.tcs.hut.fi> <20040331135449.GB62402@colin2.muc.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20040331135449.GB62402@colin2.muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 31 Mar 2004, Andi Kleen wrote:

> Ok, thanks for clarifying this. I guessed the intention wrong then.
>
> A better way may be to just add a new skb flag for this that is managed
> by the arp code? Comments?

I guess that's all right.

There just doesn't seem to be any general flag field in sk_buff that we
might use at this moment. Should one be added, or should we just hide the
flag inside the cb field using the likes of inet_skb_parm and
inet6_skb_parm?

> -Andi

Regards,
Ville

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
