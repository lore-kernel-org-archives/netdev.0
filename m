From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] Avoid gettimeofday when not needed
Date: 31 Mar 2004 17:10:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331151047.GA6033@colin2.muc.de>
References: <200403311201.i2VC13D19579@zero.aec.at> <Pine.LNX.4.58.0403311552070.19615@rhea.tcs.hut.fi> <20040331135449.GB62402@colin2.muc.de> <Pine.LNX.4.58.0403311705460.19615@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Wed, 31 Mar 2004 17:10:47 +0200
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0403311705460.19615@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 31, 2004 at 05:24:47PM +0300, Ville Nuorvala wrote:
> There just doesn't seem to be any general flag field in sk_buff that we
> might use at this moment. Should one be added, or should we just hide the
> flag inside the cb field using the likes of inet_skb_parm and
> inet6_skb_parm?

There are no free bits indeed. I think ->cb is the best choice then.


-Andi
