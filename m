From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: stmmac: First Queue must always be in DCB mode
Date: Fri, 27 Oct 2017 23:33:59 +0900 (KST)
Message-ID: <20171027.233359.1014840624120564700.davem@davemloft.net>
References: <d0f29981af9cfc700709af274acd7dba4b2014a7.1509008601.git.joabreu@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Joao.Pinto@synopsys.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
To: Jose.Abreu@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d0f29981af9cfc700709af274acd7dba4b2014a7.1509008601.git.joabreu@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jose Abreu <Jose.Abreu@synopsys.com>
Date: Thu, 26 Oct 2017 10:07:12 +0100

> According to DWMAC databook the first queue operating mode
> must always be in DCB.
> 
> As MTL_QUEUE_DCB = 1, we need to always set the first queue
> operating mode to DCB otherwise driver will think that queue
> is in AVB mode (because MTL_QUEUE_AVB = 0).
> 
> Signed-off-by: Jose Abreu <joabreu@synopsys.com>

Applied.
