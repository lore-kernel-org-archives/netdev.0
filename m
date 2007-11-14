From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 17:56:16 -0800 (PST)
Message-ID: <20071113.175616.129918600.davem@davemloft.net>
References: <20071113193750.GD1356@flint.arm.linux.org.uk>
	<473A067F.3090007@rtr.ca>
	<20071113234033.GL1356@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: liml@rtr.ca, mingo@elte.hu, alsa-devel@alsa-project.org,
 netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
 linux-kernel@vger.kernel.org, protasnb@gmail.com,
 linux-ide@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
 linux-input@atrey.karlin.mff.cuni.cz, akpm@linux-foundation.org
To: rmk+lkml@arm.linux.org.uk
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113234033.GL1356@flint.arm.linux.org.uk>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

From: Russell King <rmk+lkml@arm.linux.org.uk>
Date: Tue, 13 Nov 2007 23:40:33 +0000

> ARM ep93xx defconfig has been broken since 2.6.23-git1 due to:
> 
> drivers/net/arm/ep93xx_eth.c:420: error: implicit declaration of function '__netif_rx_schedule_prep'
> 
> caused by: [NET]: Make NAPI polling independent of struct net_device objects.
> 
> ARM netx defconfig has been broken since 2.6.23-git1 due to:
> 
> drivers/net/netx-eth.c: In function 'netx_eth_hard_start_xmit':
> drivers/net/netx-eth.c:131: error: 'dev' undeclared (first use in this function)
> drivers/net/netx-eth.c:131: error: (Each undeclared identifier is reported only once
> drivers/net/netx-eth.c:131: error: for each function it appears in.)
> drivers/net/netx-eth.c: In function 'netx_eth_receive':
> drivers/net/netx-eth.c:158: error: 'dev' undeclared (first use in this function)
> 
> caused by: [NET] drivers/net: statistics cleanup #1 -- save memory and shrink code
> 

I'll fix these up, thanks for the report.
