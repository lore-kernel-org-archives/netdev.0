From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: fix memory barriers
Date: Mon, 19 Dec 2016 11:06:55 -0500 (EST)
Message-ID: <20161219.110655.448567935176535028.davem@davemloft.net>
References: <20161218203812.GA1012@amd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LinoSanfilippo@gmx.de, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, niklas.cassel@axis.com,
        Joao.Pinto@synopsys.com
To: pavel@ucw.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161218203812.GA1012@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel@ucw.cz>
Date: Sun, 18 Dec 2016 21:38:12 +0100

> Fix up memory barriers in stmmac driver. They are meant to protect
> against DMA engine, so smp_ variants are certainly wrong, and dma_
> variants are preferable.
>     
> Signed-off-by: Pavel Machek <pavel@denx.de>

Applied.
