From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Don't access tx_q->dirty_tx before
 netif_tx_lock
Date: Sun, 22 Oct 2017 03:25:05 +0100 (WEST)
Message-ID: <20171022.032505.1139984864002614492.davem@davemloft.net>
References: <AM5PR0701MB2657DAF1EEA20231A0FFF50EE4400@AM5PR0701MB2657.eurprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bernd.edlinger@hotmail.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM5PR0701MB2657DAF1EEA20231A0FFF50EE4400@AM5PR0701MB2657.eurprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernd Edlinger <bernd.edlinger@hotmail.de>
Date: Sat, 21 Oct 2017 06:51:30 +0000

> This is the possible reason for different hard to reproduce
> problems on my ARMv7-SMP test system.
> 
> The symptoms are in recent kernels imprecise external aborts,
> and in older kernels various kinds of network stalls and
> unexpected page allocation failures.
> 
> My testing indicates that the trouble started between v4.5 and v4.6
> and prevails up to v4.14.
> 
> Using the dirty_tx before acquiring the spin lock is clearly
> wrong and was first introduced with v4.6.
> 
> Fixes: e3ad57c96715 ("stmmac: review RX/TX ring management")
> 
> Signed-off-by: Bernd Edlinger <bernd.edlinger@hotmail.de>

Applied, thank you.
