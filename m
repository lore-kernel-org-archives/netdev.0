From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 0/4] Remove various orphaned header files
Date: Thu, 28 Aug 2014 09:03:58 -0400
Message-ID: <53FF28BE.60502@windriver.com>
References: <1409226274-3202-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409226274-3202-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14-08-28 07:44 AM, Rasmus Villemoes wrote:
> These four files are not included anywhere, and seem to be accidental
> leftovers from past cleanups (see the individual commit messages).
> 
> Rasmus Villemoes (4):
>   include/linux/cycx_x25.h: Remove unused header
>   include/linux/i82593.h: Remove unused header
>   include/linux/phonedev.h: Remove unused header
>   include/rxrpc/types.h: Remove unused header

Strictly speaking the phonedev.h and types.h were not orphaned
by net-next commits, but I suppose it is no harm if they go
via net-next vs. say 3 in Greg's staging and 4 in akpm's tree.

I double checked that they are not used anywhere with
git grep, so...

Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Thanks,
Paul.
--

> 
>  include/linux/cycx_x25.h | 125 --------------------------
>  include/linux/i82593.h   | 229 -----------------------------------------------
>  include/linux/phonedev.h |  25 ------
>  include/rxrpc/types.h    |  41 ---------
>  4 files changed, 420 deletions(-)
>  delete mode 100644 include/linux/cycx_x25.h
>  delete mode 100644 include/linux/i82593.h
>  delete mode 100644 include/linux/phonedev.h
>  delete mode 100644 include/rxrpc/types.h
> 
