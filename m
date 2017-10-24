From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] net: mvpp2: fix TSO headers allocation and
 management
Date: Tue, 24 Oct 2017 18:34:38 +0900 (KST)
Message-ID: <20171024.183438.1817806547910780694.davem@davemloft.net>
References: <20171023132431.5756-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ymarkman@marvell.com, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023132431.5756-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Mon, 23 Oct 2017 15:24:29 +0200

> From: Yan Markman <ymarkman@marvell.com>
> 
> TSO headers are managed with txq index and therefore should be aligned
> with the txq size, not with the aggregated txq size.
> 
> Fixes: 186cd4d4e414 ("net: mvpp2: software tso support")
> Reported-by: Marc Zyngier <marc.zyngier@arm.com>
> Signed-off-by: Yan Markman <ymarkman@marvell.com>
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Applied.
