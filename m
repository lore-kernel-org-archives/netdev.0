From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Patch]r8169: remove unnecessary cast of readl()'s return value
Date: Sun, 30 May 2010 13:36:12 -0400
Message-ID: <4C02A20C.5010007@garzik.org>
References: <20100530122606.GC1146@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:61722 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701Ab0E3RgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 13:36:16 -0400
Received: by gyg13 with SMTP id 13so2184592gyg.19
        for <netdev@vger.kernel.org>; Sun, 30 May 2010 10:36:15 -0700 (PDT)
In-Reply-To: <20100530122606.GC1146@host-a-55.ustcsz.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2010 08:26 AM, Junchang Wang wrote:
> readl() returns a 32-bit integer on all platforms.
> There is no need to cast its return value.
>
> Signed-off-by: Junchang Wang<junchangwang@gmail.com>
> ---
>   drivers/net/r8169.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 217e709..ca93cdf 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -88,7 +88,7 @@ static const int multicast_filter_limit = 32;
>   #define RTL_W32(reg, val32)	writel ((val32), ioaddr + (reg))
>   #define RTL_R8(reg)		readb (ioaddr + (reg))
>   #define RTL_R16(reg)		readw (ioaddr + (reg))
> -#define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
> +#define RTL_R32(reg)		readl (ioaddr + (reg))

Ditto last email:  have you verified this matches all arch's definition 
of readl()?

	Jeff




