From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: uninline sh_eth_{write|read}()
Date: Mon, 14 Dec 2015 16:25:55 -0500 (EST)
Message-ID: <20151214.162555.1844850396449382434.davem@davemloft.net>
References: <4404920.p7TanuLbY1@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	ben.hutchings@codethink.co.uk
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4404920.p7TanuLbY1@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 13 Dec 2015 01:44:50 +0300

> Commit 3365711df024 ("sh_eth: WARN on access to a register not implemented in
> in  a particular chip") added WARN_ON() to sh_eth_{read|write}(), thus making
> it  unacceptable for these functions to be *inline* anymore. Remove *inline*
> and move the functions from the header to the driver itself. Below   is our
> code economy with ARM gcc 4.7.3:
> 
> $ size drivers/net/ethernet/renesas/sh_eth.o{~,}
>    text	   data	    bss	    dec	    hex	filename
>   32489	   1140	      0	  33629	   835d	drivers/net/ethernet/renesas/sh_eth.o~
>   25413	   1140	      0	  26553	   67b9	drivers/net/ethernet/renesas/sh_eth.o
> 
> Suggested-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
