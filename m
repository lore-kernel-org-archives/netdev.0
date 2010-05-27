From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: Re: [patch 2/2] be2net: remove superfluous externs
Date: Thu, 27 May 2010 12:02:54 +0530
Message-ID: <20100527063252.GB12380@serverengines.com>
References: <20100526144739.GM22515@bicker>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sathya Perla <sathyap@serverengines.com>,
	Subbu Seetharaman <subbus@serverengines.com>,
	Ajit Khaparde <ajitk@serverengines.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:54978 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751039Ab0E0Gcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 02:32:52 -0400
Content-Disposition: inline
In-Reply-To: <20100526144739.GM22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks.

Acked-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
On 26/05/10 16:47 +0200, Dan Carpenter wrote:
> This fixes some sparse warnings:
> drivers/net/benet/be_cmds.c:1503:12: warning: function
> 	'be_cmd_enable_magic_wol' with external linkage has definition
> drivers/net/benet/be_cmds.c:1668:12: warning: function
> 	'be_cmd_get_seeprom_data' with external linkage has definition
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
> index c911bfb..f9c0d4d 100644
> --- a/drivers/net/benet/be_cmds.c
> +++ b/drivers/net/benet/be_cmds.c
> @@ -1497,7 +1500,7 @@ err:
>  	return status;
>  }
>  
> -extern int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
> +int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
>  				struct be_dma_mem *nonemb_cmd)
>  {
>  	struct be_mcc_wrb *wrb;
> @@ -1662,7 +1665,7 @@ err:
>  	return status;
>  }
>  
> -extern int be_cmd_get_seeprom_data(struct be_adapter *adapter,
> +int be_cmd_get_seeprom_data(struct be_adapter *adapter,
>  				struct be_dma_mem *nonemb_cmd)
>  {
>  	struct be_mcc_wrb *wrb;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
