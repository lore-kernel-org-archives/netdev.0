From: Tien Hock Loh <thloh@altera.com>
Subject: Re: [PATCH V5 1/1] net: ethernet: Add TSE PCS support to
 dwmac-socfpga
Date: Tue, 28 Jun 2016 02:58:55 -0700
Message-ID: <1467107935.2700.2.camel@ubuntu>
References: <1466759603-30769-1-git-send-email-thloh@altera.com>
	 <20160628.053450.2071467949973087029.davem@davemloft.net>
	 <20160628.054815.1440008157228833144.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
	<peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
	<preid@electromag.com.au>, <dinguyen@opensource.altera.com>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <thloh85@gmail.com>,
	<cnphoon@altera.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0078.outbound.protection.outlook.com ([65.55.169.78]:18678
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752156AbcF1J7K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 05:59:10 -0400
In-Reply-To: <20160628.054815.1440008157228833144.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My fault, I wasn't testing against building as module, was always
building as part of the kernel. I'll get it fixed and put another patch
for review.

Thanks
Tien Hock

On Tue, 2016-06-28 at 05:48 -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 28 Jun 2016 05:34:50 -0400 (EDT)
> 
> > From: <thloh@altera.com>
> > Date: Fri, 24 Jun 2016 02:13:23 -0700
> > 
> >> From: Tien Hock Loh <thloh@altera.com>
> >> 
> >> This adds support for TSE PCS that uses SGMII adapter when the phy-mode of
> >> the dwmac is set to sgmii.
> >> 
> >> Signed-off-by: Tien Hock Loh <thloh@altera.com>
> >> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> >> Acked-by: Rob Herring <robh@kernel.org>
> > 
> > Applied to net-next, thanks.
> 
> I had to revert, this breaks the build:
> 
> ERROR: "tse_pcs_fix_mac_speed" [drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.ko] undefined!
> ERROR: "tse_pcs_init" [drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.ko] undefined!
