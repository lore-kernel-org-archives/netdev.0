From: Kirill Smelkov <kirr@nexedi.com>
Subject: Re: linux-next: Signed-off-by missing for commit in the net-next tree
Date: Wed, 1 Nov 2017 15:15:07 +0300
Message-ID: <20171101121507.vzyklrtx6buwy7z6@deco.navytux.spb.ru>
References: <20171031164019.164de3db@canb.auug.org.au>
 <20171031061429.mtq4tc5kwla7lvwv@deco.navytux.spb.ru>
 <20171101105524.GA23073@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171101105524.GA23073@electric-eye.fr.zoreil.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois,

On Wed, Nov 01, 2017 at 11:55:24AM +0100, Francois Romieu wrote:
> Kirill Smelkov <kirr@nexedi.com> :
> [...]
> > I was keeping you in To and Cc all the time but got no reply at all since my
> > first posting from ~ 1 month ago.
> 
> I thought it was longer than that. Sorry for the frustrating excess delay.
> 
> As Eric already said there is no problem and I am perfectly fine with
> the current attribution of this code.

Thanks for feedback.

> Use of errno.h::ELNRNG is really unusual but it's a different topic.

I wanted the error returned due to internal inconsistency to be different
from the error returned when there is error in provided parameters from
ethtool.

Your original patch was returning EINVAL for both cases which made it
hard to understand what is going on when the kernel was refusing to
accept something from user.

That's why I used ELNRNG (link number out of range) for situation when
lookup of timings vector by current link speed failed. A bit unusual,
yes, but this was the closest to the situation after studying `errno -l`
output.

Hope this clarifies a bit.

Please feel free to suggest a change here,
Kirill
