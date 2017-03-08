From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 7/8] net: stmicro: prepare irq_status for mtl
Date: Wed, 08 Mar 2017 11:17:27 -0800 (PST)
Message-ID: <20170308.111727.2131799324267281647.davem@davemloft.net>
References: <cover.1488969672.git.jpinto@synopsys.com>
        <cover.1488969672.git.jpinto@synopsys.com>
        <f374cfa9db1de13ea20c72c48ea21a35b4535e8b.1488969672.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52962 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752620AbdCHTYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 14:24:34 -0500
In-Reply-To: <f374cfa9db1de13ea20c72c48ea21a35b4535e8b.1488969672.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Wed,  8 Mar 2017 11:03:14 +0000

> +static int dwmac4_irq_mtl_status(struct mac_device_info *hw, u32 chan)
> +{
> +	void __iomem *ioaddr = hw->pcsr;
> +	u32 mtl_int_qx_status = readl(ioaddr + MTL_INT_STATUS);
> +	int ret = 0;

Please order local variable declarations from longest to shortest
line.
