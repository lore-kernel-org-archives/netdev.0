From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3] llc: Make llc_sap_action_t function pointer arrays
 const
Date: Wed, 10 Dec 2014 15:22:04 -0500 (EST)
Message-ID: <20141210.152204.1151872702114872181.davem@davemloft.net>
References: <1418228330.18092.3.camel@perches.com>
	<1418233437.18092.7.camel@perches.com>
	<1418234150.18092.9.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418234150.18092.9.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 10 Dec 2014 09:55:50 -0800

> It's better when function pointer arrays aren't modifiable.
> 
> Net change:
> 
> $ size net/llc/built-in.o.*
>    text	   data	    bss	    dec	    hex	filename
>   61193	  12758	   1344	  75295	  1261f	net/llc/built-in.o.new
>   47113	  27030	   1344	  75487	  126df	net/llc/built-in.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
