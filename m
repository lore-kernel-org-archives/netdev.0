From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: explicitly zero des0 & des1 on init
Date: Sun, 21 Jun 2015 09:29:48 -0700 (PDT)
Message-ID: <20150621.092948.394430183523491972.davem@davemloft.net>
References: <1434476441-18241-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	arc-linux-dev@synopsys.com, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: Alexey.Brodkin@synopsys.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1434476441-18241-1-git-send-email-abrodkin@synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Tue, 16 Jun 2015 20:40:41 +0300

> Current implementtion of descriptor init procedure only takes care about
> ownership flag. While it is perfectly possible to have underlying memory
> filled with garbage on boot or driver installation.
> 
> And randomly set flags in non-zeroed des0 and des1 fields may lead to
> unpredictable behavior of the GMAC DMA block.
> 
> Solution to this problem is as simple as explicit zeroing of both des0
> and des1 fields of all buffer descriptors.
> 
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

If you need the memory zero initialized, use dma_zalloc_coherent().
