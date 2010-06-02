From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] mac8390: propagate error code from request_irq
Date: Wed, 02 Jun 2010 05:17:07 -0700 (PDT)
Message-ID: <20100602.051707.170100284.davem@davemloft.net>
References: <alpine.OSX.2.00.1005312244520.1490@localhost>
	<20100531.060225.68146363.davem@davemloft.net>
	<alpine.OSX.2.00.1006011738330.299@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, joe@perches.com, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.OSX.2.00.1006011738330.299@localhost>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Tue, 1 Jun 2010 22:18:32 +1000 (EST)

> 
> Use the request_irq() error code as the return value for mac8390_open(). 
> EAGAIN doesn't make sense for Nubus slot IRQs. Only this driver can claim 
> this IRQ (until the NIC is removed, which means everything is powered 
> down).
> 
> Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

Applied.
