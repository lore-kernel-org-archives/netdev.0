From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ewrk3: silence GCC warning
Date: Wed, 28 Nov 2012 11:35:30 -0500 (EST)
Message-ID: <20121128.113530.1758331048704686053.davem@davemloft.net>
References: <1354009637.1420.50.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	richard.weinberger@gmail.com
To: pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354009637.1420.50.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bolle <pebolle@tiscali.nl>
Date: Tue, 27 Nov 2012 10:47:17 +0100

> Building ewrk3.o triggers this GCC warning:
>     drivers/net/ethernet/dec/ewrk3.c: In function '__check_irq':
>     drivers/net/ethernet/dec/ewrk3.c:1915:1: warning: return from incompatible pointer type [enabled by default]
> 
> This can be trivially fixed by changing the 'irq' parameter from int to
> byte (which is an alias for unsigned char for module parameters).
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>

Applied.
