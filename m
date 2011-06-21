From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove mm.h inclusion from netdevice.h
Date: Tue, 21 Jun 2011 16:25:07 -0700 (PDT)
Message-ID: <20110621.162507.453473443486815179.davem@davemloft.net>
References: <20110616210134.GA18026@p183.telecom.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fujita.tomonori@lab.ntt.co.jp, linux-arch@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20110616210134.GA18026@p183.telecom.by>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 17 Jun 2011 00:01:34 +0300

> Remove linux/mm.h inclusion from netdevice.h -- it's unused (I've checked manually).
> 
> To prevent mm.h inclusion via other channels also extract "enum dma_data_direction"
> definition into separate header. This tiny piece is what gluing netdevice.h with mm.h
> via "netdevice.h => dmaengine.h => dma-mapping.h => scatterlist.h => mm.h".
> Removal of mm.h from scatterlist.h was tried and was found not feasible
> on most archs, so the link was cutoff earlier.
> 
> Hope people are OK with tiny include file.
> 
> Note, that mm_types.h is still dragged in, but it is a separate story.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

I've applied this, thanks.
