From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: do not invalidate cache for RX buffer twice
Date: Fri, 17 Jul 2015 00:11:41 -0700 (PDT)
Message-ID: <20150717.001141.1945286438330434553.davem@davemloft.net>
References: <4759713.2ulGRKsd9L@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4759713.2ulGRKsd9L@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 15 Jul 2015 00:56:52 +0300

> First, dma_sync_single_for_cpu() shouldn't have been called in the first place
> (it's a streaming DMA API). dma_unmap_single() should have been called instead.
> Second, dma_unmap_single() call after handing the buffer to napi_gro_receive()
> makes little sense.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied with fixed up commit log message, thanks.
