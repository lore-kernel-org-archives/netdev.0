From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] include/linux/skbuff.h: using '(__u16) ~0U' instead
 of '~0U'
Date: Wed, 05 Jun 2013 01:36:01 -0700 (PDT)
Message-ID: <20130605.013601.2203042571724866964.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7263@saturn3.aculab.com>
	<51AE89DE.60106@asianux.com>
	<51AE8C3E.8060605@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, andy.shevchenko@gmail.com,
	edumazet@google.com, pshelar@nicira.com, mgorman@suse.de,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: gang.chen@asianux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51AE8C3E.8060605@asianux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chen Gang <gang.chen@asianux.com>
Date: Wed, 05 Jun 2013 08:54:22 +0800

> 
> Both 'transport_header' and 'mac_header' are __u16, which are
> never equal to '~0U'.
> 
> So need use '(__u16) ~0U' instead of '~0U'.
> 
> The related warning (with EXTRA_CFLAGS=-W ARCH=m68k for allmodconfig)
>   include/linux/skbuff.h:1587:2: warning: comparison is always true due to limited range of data type [-Wtype-limits]
>   ...
> 
> Use meaningful macro instead of hard code number, and better to
> initialize 'skb->transport_header' in __alloc_skb_head(), too.
> 
> 
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

Your patch doesn't apply to the tree because this has been fixed already
for several days by using "typeof(x) ~0U"
