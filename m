From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 5/5] ARM: davinci: da850: add OF_DEV_AUXDATA entry
 for eth0.
Date: Thu, 15 Aug 2013 23:31:58 +0400
Message-ID: <520D2CAE.3090501@cogentembedded.com>
References: <1376546497-26931-1-git-send-email-prabhakar.csengg@gmail.com> <1376546497-26931-6-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>,
	DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376546497-26931-6-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 15-08-2013 10:01, Lad, Prabhakar wrote:

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

> Add OF_DEV_AUXDATA for eth0  driver in da850 board dt
> file to use emac clock.

> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
[...]

> diff --git a/arch/arm/mach-davinci/da8xx-dt.c b/arch/arm/mach-davinci/da8xx-dt.c
> index d172563..caa9202 100644
> --- a/arch/arm/mach-davinci/da8xx-dt.c
> +++ b/arch/arm/mach-davinci/da8xx-dt.c
> @@ -44,6 +44,9 @@ static struct of_dev_auxdata da850_auxdata_lookup[] __initdata = {
>   	OF_DEV_AUXDATA("ns16550a", 0x01d0c000, "serial8250.1", NULL),
>   	OF_DEV_AUXDATA("ns16550a", 0x01d0d000, "serial8250.2", NULL),
>   	OF_DEV_AUXDATA("ti,davinci_mdio", 0x01e24000, "davinci_mdio.0", NULL),
> +	OF_DEV_AUXDATA("ti,davinci-dm6467-emac", 0x01e20000, "davinci_emac.1",
> +		       NULL),
> +

    Empty line hardly needed here.

>   	{}
>   };

WBR, Sergei
