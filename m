From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] net: mvpp2: do not unmap TSO headers buffers
Date: Tue, 24 Oct 2017 18:34:48 +0900 (KST)
Message-ID: <20171024.183448.1039880641989092213.davem@davemloft.net>
References: <20171023132431.5756-1-antoine.tenart@free-electrons.com>
        <20171023132431.5756-2-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023132431.5756-2-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Mon, 23 Oct 2017 15:24:30 +0200

> The TSO header buffers are coming from a per cpu pool and should not
> be unmapped as they are reused. The PPv2 driver was unmapping all
> descriptors buffers unconditionally. This patch fixes this by checking
> the buffers dma addresses before unmapping them, and by not unmapping
> those who are located in the TSO header pool.
> 
> Fixes: 186cd4d4e414 ("net: mvpp2: software tso support")
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Applied.
