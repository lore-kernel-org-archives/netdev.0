From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ravb: minimize TX data copying
Date: Mon, 27 Jul 2015 01:22:59 -0700 (PDT)
Message-ID: <20150727.012259.913287007411624198.davem@davemloft.net>
References: <6916181.NMDRL3LUfS@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <6916181.NMDRL3LUfS@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 25 Jul 2015 23:42:01 +0300

> Renesas Ethernet AVB controller requires that all data are aligned on 4-byte
> boundary.  While it's  easily achievable for  the RX  data with  the help of
> skb_reserve() (we even align on 128-byte boundary as recommended by the manual),
> we  can't  do the same with the TX data, and it always comes  unaligned from
> the networking core. Originally we solved it an easy way, copying all packet
> to  a  preallocated  aligned buffer; however, it's enough to copy only up to
> 3 first bytes from each packet, doing the transfer using 2 TX descriptors
> instead of just 1. Here's an implementation of the new  TX algorithm that
> significantly reduces the driver's memory requirements.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
