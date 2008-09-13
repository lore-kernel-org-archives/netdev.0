From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] smc91x: SMC_IO_SHIFT platform data support for default
 case
Date: Sat, 13 Sep 2008 15:13:04 -0400
Message-ID: <48CC10C0.6040607@garzik.org>
References: <20080908050234.11554.10123.sendpatchset@rx1.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.miao@marvell.com,
	luca.santini@spesonline.com, nico@cam.org, linux-sh@vger.kernel.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20080908050234.11554.10123.sendpatchset@rx1.opensource.se>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Magnus Damm wrote:
> From: Magnus Damm <damm@igel.co.jp>
> 
> Commit 159198862adad7109bb347bb30a620f67beac45f added SMC_IO_SHIFT
> platform data support. After that ARM board support was added.
> 
> The default case is still missing though, so on SuperH SMC_IO_SHIFT
> is constantly zero regardless of what you pass as platform data.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> Test-by: Luca Santini <luca.santini@spesonline.com>
> ---
> 
>  drivers/net/smc91x.h |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- 0001/drivers/net/smc91x.h
> +++ work/drivers/net/smc91x.h	2008-08-28 20:43:03.000000000 +0900
> @@ -446,6 +446,8 @@ static inline void LPD7_SMC_outsw (unsig
>  #define SMC_CAN_USE_32BIT	1
>  #define SMC_NOWAIT		1
>  
> +#define SMC_IO_SHIFT		(lp->io_shift)
> +
>  #define SMC_inb(a, r)		readb((a) + (r))
>  #define SMC_inw(a, r)		readw((a) + (r))
>  #define SMC_inl(a, r)		readl((a) + (r))

applied


