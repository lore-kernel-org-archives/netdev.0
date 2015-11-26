From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v2 net 2/6] net: mvneta: fix bit assignment in
 MVNETA_RXQ_CONFIG_REG
Date: Thu, 26 Nov 2015 19:27:36 +0100
Message-ID: <20151126192736.662634d3@free-electrons.com>
References: <1448561293-16431-1-git-send-email-mw@semihalf.com>
	<1448561293-16431-3-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux@arm.linux.org.uk, sebastian.hesselbarth@gmail.com,
	andrew@lunn.ch, jason@lakedaemon.net,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, jaz@semihalf.com,
	tn@semihalf.com, <stable@vger.kernel.org>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1448561293-16431-3-git-send-email-mw@semihalf.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Marcin Wojtas,

On Thu, 26 Nov 2015 19:08:09 +0100, Marcin Wojtas wrote:
> MVNETA_RXQ_HW_BUF_ALLOC bit which controls enabling hardware buffer
> allocation was mistakenly set as BIT(1). This commit fixes the assignment.
> 
> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
> Reviewed-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Cc: <stable@vger.kernel.org> # v3.8+
> Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network
> unit")
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

What is the user-visible impact of this bug? Indeed, the code is wrong,
but things were working fine until now.

So I am not questioning that this patch should be merged, but only
questioning whether the stable tag is appropriate.

Same questions for your patch 3/6.

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
