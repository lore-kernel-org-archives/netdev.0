From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] [NET] cpmac: convert to new Fixed PHY infrastructure (was: Re: fixed phy support (warning related to FIXED_MII_100_FDX))
Date: Wed, 30 Jan 2008 22:30:38 -0600
Message-ID: <B4093288-C5F4-472D-BA13-EA83C616A0D6@kernel.crashing.org>
References: <416B8C5D-109C-4C03-807D-7EBB0AA9C366@kernel.crashing.org> <20080121204953.GA11384@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v915)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Eugene Konev <ejka@imfi.kspu.ru>
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48680 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754682AbYAaEbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 23:31:24 -0500
In-Reply-To: <20080121204953.GA11384@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Anton Vorontsov <avorontsov@ru.mvista.com>
> Subject: [PATCH] [NET] cpmac: convert to new Fixed PHY infrastructure
>
> This patch converts cpmac to the new Fixed PHY infrastructure,  
> though it
> doesn't fix all the problems with that driver. I didn't even bother to
> test this patch to compile, because cpmac driver is broken in  
> several ways:
>
> 1. This driver won't compile by itself because lack of its header  
> describing
>   platform data;
> 2. It assumes that fixed PHYs should be created by the ethernet  
> driver.
>   It is wrong assumption: fixed PHYs creation is platform code  
> authority,
>   driver must blindly accept bus_id and phy_id platform data variables
>   instead.
>
> Also, it seem that that driver doesn't have actual in-tree users, so
> nothing to fix further.
>
> The main purpose of that patch is to get rid of the following Kconfig
> warning:
>
> scripts/kconfig/conf -s arch/powerpc/Kconfig
> drivers/net/Kconfig:1713:warning: 'select' used by config symbol
> 'CPMAC' refers to undefined symbol 'FIXED_MII_100_FDX'
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
> drivers/net/Kconfig |    4 +--
> drivers/net/cpmac.c |   55 +++++++++++++++ 
> +----------------------------------
> 2 files changed, 19 insertions(+), 40 deletions(-)

applied.

- k

