From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5 4/5] net: ethernet: cpsw: add support for hardware
 interface mode config
Date: Fri, 23 Aug 2013 23:18:05 +0400
Message-ID: <5217B56D.1010608@cogentembedded.com>
References: <1377283987-20040-1-git-send-email-zonque@gmail.com> <1377283987-20040-5-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcousson@baylibre.com, nsekhar@ti.com,
	davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1377283987-20040-5-git-send-email-zonque@gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/23/2013 10:53 PM, Daniel Mack wrote:

> The cpsw currently lacks code to properly set up the hardware interface
> mode on AM33xx. Other platforms might be equally affected.

> Usually, the bootloader will configure the control module register, so
> probably that's why such support wasn't needed in the past. In suspend
> mode though, this register is modified, and so it needs reprogramming
> after resume.

> This patch adds code that makes use of the previously added and optional
> support for passing the control mode register, and configures the
> correct register bits when the slave is opened.

> The AM33xx also has a bit for each slave to configure the RMII reference
> clock direction. Setting it is now supported by a per-slave DT property.

> This code path introducted by this patch is currently exclusive for
> am33xx.

> Signed-off-by: Daniel Mack <zonque@gmail.com>
[...]

> @@ -40,4 +41,11 @@ struct cpsw_platform_data {
>   	u32	hw_type;	/* hardware type as specified in 'compatible' */
>   };
>
> +/* SoC specific definitions for the CONTROL port */
> +#define AM33XX_GMII_SEL_MODE_MII	(0)
> +#define AM33XX_GMII_SEL_MODE_RMII	(1)
> +#define AM33XX_GMII_SEL_MODE_RGMII	(2)

    Parens around decimal literals are hardly needed even in macros.

WBR, Sergei

