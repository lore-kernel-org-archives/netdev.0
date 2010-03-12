From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v4 2/7] net: remove old tcp_optlen function
Date: Fri, 12 Mar 2010 11:26:41 +1100
Message-ID: <20100312002628.GB20795@verge.net.au>
References: <4B98D592.6040301@gmail.com>
 <4B98D9A2.8060603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B98D9A2.8060603@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 11, 2010 at 06:53:06AM -0500, William Allen Simpson wrote:
> The tcp_optlen() function returns a potential *negative* unsigned.
> 
> In the only two existing files using the old tcp_optlen() function,
> clean up confusing and inconsistent mixing of both byte and word
> offsets, and other coding style issues.  Document assumptions.

IIRC, Dave already pointed out that this quoting style which singles him
out isn't appropriate. Perhaps you should consider updating it if you want
him to consider merging this and other changes with similar quotes in the
changelog.

I suggest moving the "No response from testers in 21+ weeks." to
below the "--- " somewhere and dropping everything else except
the Signed-off line that appears after this point.

> Quoth David Miller:
>    This is transmit, and the packets can only come from the Linux
>    TCP stack, not some external entity.
> 
>    You're being way too anal here, and adding these checks to
>    drivers would be just a lot of rediculious bloat. [sic]
> 
> Therefore, there are *no* checks for bad TCP and IP header sizes, nor
> any semantic changes.  The drivers should function exactly as existing,
> although usage of int should ameliorate the issues.

> No response from testers in 21+ weeks.
> 
> [removed comment references to commit log]
> 
> Requires:
>   net: tcp_header_len_th and tcp_option_len_th
> 
> Signed-off-by: William.Allen.Simpson@gmail.com
> CC: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/bnx2.c  |   29 +++++++++++++-----------
>  drivers/net/tg3.c   |   60 +++++++++++++++++++++++---------------------------
>  include/linux/tcp.h |    5 ----
>  3 files changed, 44 insertions(+), 50 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
