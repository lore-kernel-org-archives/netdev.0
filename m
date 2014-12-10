From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2] llc: Make llc_conn_ev_qfyr_t function pointer arrays
 const
Date: Wed, 10 Dec 2014 15:21:57 -0500 (EST)
Message-ID: <20141210.152157.830723410034718607.davem@davemloft.net>
References: <1418228330.18092.3.camel@perches.com>
	<1418233437.18092.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418233437.18092.7.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 10 Dec 2014 09:43:57 -0800

> It's better when function pointer arrays aren't modifiable.
> 
> Net change from original:
> 
> $ size net/llc/built-in.o.*
>    text	   data	    bss	    dec	    hex	filename
>   61065	  12886	   1344	  75295	  1261f	net/llc/built-in.o.new
>   47113	  27030	   1344	  75487	  126df	net/llc/built-in.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
