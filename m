From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [PATCH 2/2] sfc: Reduce I2C udelay to 5 resulting in a clock
 frequency of 100 kHz
Date: Sat, 31 May 2008 13:19:43 +0200
Message-ID: <20080531131943.46ba0332@hyperion.delvare>
References: <cover.1212182201.git.bhutchings@solarflare.com>
	<20080530212745.GH1743@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zone0.gcu-squad.org ([212.85.147.21]:38785 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbYEaLTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 07:19:50 -0400
In-Reply-To: <20080530212745.GH1743@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 May 2008 22:27:46 +0100, Ben Hutchings wrote:
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/falcon.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
> index 8acd53d..8cb5798 100644
> --- a/drivers/net/sfc/falcon.c
> +++ b/drivers/net/sfc/falcon.c
> @@ -222,7 +222,7 @@ static struct i2c_algo_bit_data falcon_i2c_bit_operations = {
>  	.setscl		= falcon_setscl,
>  	.getsda		= falcon_getsda,
>  	.getscl		= falcon_getscl,
> -	.udelay		= 100,
> +	.udelay		= 5,
>  	/*
>  	 * This is the number of system clock ticks after which
>  	 * i2c-algo-bit gives up waiting for SCL to become high.

Acked-by: Jean Delvare <khali@linux-fr.org>

-- 
Jean Delvare
