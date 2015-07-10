From: David Miller <davem@davemloft.net>
Subject: Re: [RFT PATCH] net: axienet: Fix devm_ioremap_resource return
 value check
Date: Thu, 09 Jul 2015 21:44:05 -0700 (PDT)
Message-ID: <20150709.214405.325044957551402588.davem@davemloft.net>
References: <1436448080-24775-1-git-send-email-k.kozlowski.k@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: k.kozlowski.k@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1436448080-24775-1-git-send-email-k.kozlowski.k@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Kozlowski <k.kozlowski.k@gmail.com>
Date: Thu,  9 Jul 2015 22:21:20 +0900

> Value returned by devm_ioremap_resource() was checked for non-NULL but
> devm_ioremap_resource() returns IOMEM_ERR_PTR, not NULL. In case of
> error this could lead to dereference of ERR_PTR.
> 
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski.k@gmail.com>
> Cc: <stable@vger.kernel.org>
> Fixes: 46aa27df8853 ("net: axienet: Use devm_* calls")

Applied, thanks.
