From: Christos Gkekas <chris.gekas@gmail.com>
Subject: Re: [PATCH] vxge: Fix rts_mac_en config parameter check
Date: Sun, 24 Sep 2017 20:10:17 +0100
Message-ID: <20170924191017.GA7358@inspiron>
References: <1506279021-7164-1-git-send-email-chris.gekas@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506279021-7164-1-git-send-email-chris.gekas@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24/09/17 19:50:21 +0100, Christos Gkekas wrote:
> Current checks return VXGE_HW_BADCFG_RTS_MAC_EN if rts_mac_en is not
> equal to DISABLE *and* not equal to ENABLE. This condition is always
> false and the check should change to *or* to properly verify the value.
> 
> Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
> ---
>  drivers/net/ethernet/neterion/vxge/vxge-config.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/neterion/vxge/vxge-config.c b/drivers/net/ethernet/neterion/vxge/vxge-config.c
> index 6223930..c694f97 100644
> --- a/drivers/net/ethernet/neterion/vxge/vxge-config.c
> +++ b/drivers/net/ethernet/neterion/vxge/vxge-config.c
> @@ -1286,8 +1286,8 @@ __vxge_hw_device_config_check(struct vxge_hw_device_config *new_config)
>  	    (new_config->intr_mode != VXGE_HW_INTR_MODE_DEF))
>  		return VXGE_HW_BADCFG_INTR_MODE;
>  
> -	if ((new_config->rts_mac_en != VXGE_HW_RTS_MAC_DISABLE) &&
> -	    (new_config->rts_mac_en != VXGE_HW_RTS_MAC_ENABLE))
> +	if (new_config->rts_mac_en != VXGE_HW_RTS_MAC_DISABLE ||
> +	    new_config->rts_mac_en != VXGE_HW_RTS_MAC_ENABLE)
>  		return VXGE_HW_BADCFG_RTS_MAC_EN;
>  
>  	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
> -- 
> 2.7.4
>

Please ignore the patch above, it was sent in error.

Thanks,
Chris
