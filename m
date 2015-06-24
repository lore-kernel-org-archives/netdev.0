From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: explicitly zero des0 & des1 on init
Date: Wed, 24 Jun 2015 00:18:40 -0700 (PDT)
Message-ID: <20150624.001840.1867851321247997506.davem@davemloft.net>
References: <20150621.092948.394430183523491972.davem@davemloft.net>
	<1434955394.4269.6.camel@synopsys.com>
	<1435071870.3298.1.camel@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	arc-linux-dev@synopsys.com, peppe.cavallaro@st.com,
	stable@vger.kernel.org
To: Alexey.Brodkin@synopsys.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1435071870.3298.1.camel@synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Tue, 23 Jun 2015 15:04:31 +0000

> I'm wondering if my comment makes sense and should I just change commit
> message or you'd prefer to still use dma_zalloc_coherent() during
> driver probe?

I think you should do both, convert to dma_zalloc_coherent() and perform
the explicit clearing in the routine in question.
