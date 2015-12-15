From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: fix descriptor access endianness
Date: Tue, 15 Dec 2015 00:25:41 -0500 (EST)
Message-ID: <20151215.002541.762812772082527155.davem@davemloft.net>
References: <11070795.yxBPvlHg4n@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <11070795.yxBPvlHg4n@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 13 Dec 2015 23:05:07 +0300

> The driver never  calls cpu_to_edmac() when writing the descriptor address
> and edmac_to_cpu() when reading it, although it should -- fix this.
> 
> Note that the frame/buffer length descriptor field accesses also need fixing
> but since they are both 16-bit we can't  use {cpu|edmac}_to_{edmac|cpu}()...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
