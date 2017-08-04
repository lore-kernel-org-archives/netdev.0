From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xgene: Always get clk source, but ignore if it's
 missing for SGMII ports
Date: Fri, 04 Aug 2017 11:30:54 -0700 (PDT)
Message-ID: <20170804.113054.760644132949601023.davem@davemloft.net>
References: <20170803140311.34C7E50870B@solo.franken.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, qnguyen@apm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        labbott@redhat.com
To: tsbogend@alpha.franken.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170803140311.34C7E50870B@solo.franken.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Date: Thu, 3 Aug 2017 15:43:14 +0200

> From: Thomas Bogendoerfer <tbogendoerfer@suse.de>
> 
> Even the driver doesn't do anything with the clk source for SGMII
> ports it needs to be enabled by doing a devm_clk_get(), if there is
> a clk source in DT.
> 
> Fixes: 0db01097cabd ('xgene: Don't fail probe, if there is no clk resource for SGMII interfaces')
> Signed-off-by: Thomas Bogendoerfer <tbogendoerfer@suse.de>
> Tested-by: Laura Abbott <labbott@redhat.com>
> Acked-by: Iyappan Subramanian <isubramanian@apm.com>

Applied, thanks.
