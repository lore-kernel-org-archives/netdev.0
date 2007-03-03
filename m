From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] mv643xx_eth: Place explicit port number in mv643xx_eth_platform_data
Date: Fri, 02 Mar 2007 20:17:32 -0500
Message-ID: <45E8CCAC.7040304@garzik.org>
References: <20070301233148.GA19550@xyzzy.farnsworth.org> <20070301233324.GA20193@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, Ralf Baechle <ralf@linux-mips.org>
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55552 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992865AbXCCBRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:17:34 -0500
In-Reply-To: <20070301233324.GA20193@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> We were using the platform_device.id field to identify which ethernet
> port is used for mv643xx_eth device.  This is not generally correct.
> It will be incorrect, for example, if a hardware platform uses a single
> port but not the first port.  Here, we add an explicit port_number field
> to struct mv643xx_eth_platform_data.
> 
> This makes the mv643xx_eth_platform_data structure required, but that
> isn't an issue since all users currently provide it already.
> 
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> 
> ---
> 
>  arch/mips/momentum/jaguar_atx/platform.c  |    8 ++
>  arch/mips/momentum/ocelot_3/platform.c    |    8 ++
>  arch/mips/momentum/ocelot_c/platform.c    |    4 +
>  arch/powerpc/platforms/chrp/pegasos_eth.c |    2 
>  arch/ppc/syslib/mv64x60.c                 |   12 +++-
>  drivers/net/mv643xx_eth.c                 |   59 ++++++++++----------
>  include/linux/mv643xx.h                   |    1 
>  7 files changed, 62 insertions(+), 32 deletions(-)

ACK but not applied, patch corrupted


