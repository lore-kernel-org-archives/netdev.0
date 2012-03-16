From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] ethtool: Added a field fw dump_state
Date: Fri, 16 Mar 2012 18:27:36 +0000
Message-ID: <1331922456.2504.0.camel@bwh-desktop.uk.solarflarecom.com>
References: <1331920711-16049-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish chopra <manish.chopra@qlogic.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59261 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751534Ab2CPS1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 14:27:42 -0400
In-Reply-To: <1331920711-16049-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-16 at 10:58 -0700, Anirban Chakraborty wrote:
> From: Manish chopra <manish.chopra@qlogic.com>
> 
> This field is added to enable/disable firmware dump.
> 
> Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> ---
>  include/linux/ethtool.h |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index e1d9e0e..6ebc7de 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -666,15 +666,22 @@ struct ethtool_flash {
>   * 	 %ETHTOOL_GET_DUMP_DATA and this is returned as dump length by driver
>   * 	 for %ETHTOOL_GET_DUMP_FLAG command
>   * @data: data collected for get dump data operation
> + * @dump_state: state of the firmware dump. which can be enable/disable.
>   */
> +
> +#define ETH_FW_DUMP_ENABLE	1
> +#define ETH_FW_DUMP_DISABLE	0
> +
>  struct ethtool_dump {
>  	__u32	cmd;
>  	__u32	version;
>  	__u32	flag;
>  	__u32	len;
>  	__u8	data[0];
> +	__u8	dump_state;

Don't be ridiculous.

Ben.

>  };
>  
> +
>  /* for returning and changing feature sets */
>  
>  /**

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
