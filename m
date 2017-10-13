From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 5/5] fsl/fman: add dpaa in module names
Date: Fri, 13 Oct 2017 10:39:08 -0700
Message-ID: <ba387138-03e5-52df-dc5b-98c6c9d57be8@gmail.com>
References: <1507906212-10076-1-git-send-email-madalin.bucur@nxp.com>
 <1507906212-10076-6-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        junote@outlook.com, linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507906212-10076-6-git-send-email-madalin.bucur@nxp.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/13/2017 07:50 AM, Madalin Bucur wrote:
> Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>

You should provide a line or two to explain why are you making this
change, it is to resolve modular build configurations?

> ---
>  drivers/net/ethernet/freescale/fman/Makefile | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fman/Makefile b/drivers/net/ethernet/freescale/fman/Makefile
> index 2c38119..4ae524a 100644
> --- a/drivers/net/ethernet/freescale/fman/Makefile
> +++ b/drivers/net/ethernet/freescale/fman/Makefile
> @@ -1,9 +1,9 @@
>  subdir-ccflags-y +=  -I$(srctree)/drivers/net/ethernet/freescale/fman
>  
> -obj-$(CONFIG_FSL_FMAN) += fsl_fman.o
> -obj-$(CONFIG_FSL_FMAN) += fsl_fman_port.o
> -obj-$(CONFIG_FSL_FMAN) += fsl_mac.o
> +obj-$(CONFIG_FSL_FMAN) += fsl_dpaa_fman.o
> +obj-$(CONFIG_FSL_FMAN) += fsl_dpaa_fman_port.o
> +obj-$(CONFIG_FSL_FMAN) += fsl_dpaa_mac.o
>  
> -fsl_fman-objs	:= fman_muram.o fman.o fman_sp.o fman_keygen.o
> -fsl_fman_port-objs := fman_port.o
> -fsl_mac-objs:= mac.o fman_dtsec.o fman_memac.o fman_tgec.o
> +fsl_dpaa_fman-objs	:= fman_muram.o fman.o fman_sp.o fman_keygen.o
> +fsl_dpaa_fman_port-objs := fman_port.o
> +fsl_dpaa_mac-objs:= mac.o fman_dtsec.o fman_memac.o fman_tgec.o
> 


-- 
Florian
