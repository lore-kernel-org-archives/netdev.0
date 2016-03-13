From: isdn@linux-pingi.de
Subject: Re: [PATCH 1/2] mISDN: Order IPAC register defines
Date: Sun, 13 Mar 2016 04:13:20 +0100
Message-ID: <56E4DAD0.3040800@linux-pingi.de>
References: <56E4A3AE.8050407@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E4A3AE.8050407@maciej.szmigiero.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Karsten Keil <keil@b1-systems.de>
Am 13.03.2016 um 00:18 schrieb Maciej S. Szmigiero:
> It looks like IPAC/ISAC chips register defines weren't in any particular
> order.
> 
> Order them by their number to make it easier to spot holes.
> 
> Signed-off-by: Maciej S. Szmigiero <mail@maciej.szmigiero.name>
> ---
>  drivers/isdn/hardware/mISDN/ipac.h | 40 +++++++++++++++++++-------------------
>  1 file changed, 20 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/isdn/hardware/mISDN/ipac.h b/drivers/isdn/hardware/mISDN/ipac.h
> index 8121e046b739..76aa6f8f298e 100644
> --- a/drivers/isdn/hardware/mISDN/ipac.h
> +++ b/drivers/isdn/hardware/mISDN/ipac.h
> @@ -99,32 +99,32 @@ struct ipac_hw {
>  
>  /* All registers original Siemens Spec  */
>  /* IPAC/ISAC registers */
> -#define ISAC_MASK		0x20
>  #define ISAC_ISTA		0x20
> -#define ISAC_STAR		0x21
> +#define ISAC_MASK		0x20
>  #define ISAC_CMDR		0x21
> +#define ISAC_STAR		0x21
> +#define ISAC_MODE		0x22
> +#define ISAC_TIMR		0x23
>  #define ISAC_EXIR		0x24
> -#define ISAC_ADF2		0x39
> +#define ISAC_RBCL		0x25
> +#define ISAC_RSTA		0x27
> +#define ISAC_RBCH		0x2A
>  #define ISAC_SPCR		0x30
> -#define ISAC_ADF1		0x38
>  #define ISAC_CIR0		0x31
>  #define ISAC_CIX0		0x31
> -#define ISAC_CIR1		0x33
> -#define ISAC_CIX1		0x33
> -#define ISAC_STCR		0x37
> -#define ISAC_MODE		0x22
> -#define ISAC_RSTA		0x27
> -#define ISAC_RBCL		0x25
> -#define ISAC_RBCH		0x2A
> -#define ISAC_TIMR		0x23
> -#define ISAC_SQXR		0x3b
> -#define ISAC_SQRR		0x3b
> -#define ISAC_MOSR		0x3a
> -#define ISAC_MOCR		0x3a
>  #define ISAC_MOR0		0x32
>  #define ISAC_MOX0		0x32
> +#define ISAC_CIR1		0x33
> +#define ISAC_CIX1		0x33
>  #define ISAC_MOR1		0x34
>  #define ISAC_MOX1		0x34
> +#define ISAC_STCR		0x37
> +#define ISAC_ADF1		0x38
> +#define ISAC_ADF2		0x39
> +#define ISAC_MOCR		0x3a
> +#define ISAC_MOSR		0x3a
> +#define ISAC_SQRR		0x3b
> +#define ISAC_SQXR		0x3b
>  
>  #define ISAC_RBCH_XAC		0x80
>  
> @@ -212,13 +212,13 @@ struct ipac_hw {
>  #define ISAC_CMD_DUI		0xF
>  
>  /* ISAC/ISACX/IPAC/IPACX L1 indications */
> -#define ISAC_IND_RS		0x1
> -#define ISAC_IND_PU		0x7
>  #define ISAC_IND_DR		0x0
> +#define ISAC_IND_RS		0x1
>  #define ISAC_IND_SD		0x2
>  #define ISAC_IND_DIS		0x3
> -#define ISAC_IND_EI		0x6
>  #define ISAC_IND_RSY		0x4
> +#define ISAC_IND_EI		0x6
> +#define ISAC_IND_PU		0x7
>  #define ISAC_IND_ARD		0x8
>  #define ISAC_IND_TI		0xA
>  #define ISAC_IND_ATI		0xB
> @@ -339,9 +339,9 @@ struct ipac_hw {
>  #define ISACX__AUX		0x08
>  #define ISACX__CIC		0x10
>  #define ISACX__ST		0x20
> +#define IPACX__ON		0x2C
>  #define IPACX__ICB		0x40
>  #define IPACX__ICA		0x80
> -#define IPACX__ON		0x2C
>  
>  /* ISACX/IPACX _CMDRD (W) */
>  #define ISACX_CMDRD_XRES	0x01
> 
> 
