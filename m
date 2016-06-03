From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rxrpc: Use pr_<level> and pr_fmt, reduce object size a
 few KB
Date: Fri, 03 Jun 2016 19:41:48 -0400 (EDT)
Message-ID: <20160603.194148.2116642486783888748.davem@davemloft.net>
References: <c7437f437c30addd6dafa35b87d7c57061dc752b.1464894331.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, rjui@broadcom.com, sbranden@broadcom.com,
	jonmason@broadcom.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c7437f437c30addd6dafa35b87d7c57061dc752b.1464894331.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu,  2 Jun 2016 12:08:52 -0700

> Use the more common kernel logging style and reduce object size.
> 
> The logging message prefix changes from a mixture of
> "RxRPC:" and "RXRPC:" to "af_rxrpc: ".
> 
> $ size net/rxrpc/built-in.o*
>    text	   data	    bss	    dec	    hex	filename
>   64172	   1972	   8304	  74448	  122d0	net/rxrpc/built-in.o.new
>   67512	   1972	   8304	  77788	  12fdc	net/rxrpc/built-in.o.old
> 
> Miscellanea:
> 
> o Consolidate the ASSERT macros to use a single pr_err call with
>   decimal and hexadecimal output and a stringified #OP argument
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Looks good to me, applied, thanks Joe.
