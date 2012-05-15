From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH NEXT 1/2] linux/ethtool: Added macro ETH_FW_DUMP_DISABLE
Date: Tue, 15 May 2012 15:01:54 +0100
Message-ID: <1337090514.2544.0.camel@bwh-desktop.uk.solarflarecom.com>
References: <1337080419-31786-1-git-send-email-manish.chopra@qlogic.com>
	 <1337080419-31786-2-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	<anirban.chakraborty@qlogic.com>
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41715 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753130Ab2EOOCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 10:02:00 -0400
In-Reply-To: <1337080419-31786-2-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-15 at 07:13 -0400, Manish Chopra wrote:
> From: Manish chopra <manish.chopra@qlogic.com>
> 
> o flag field of ethtool_dump structure must be initialized by this macro
> value that is zero, if the firmware dump is disabled.
> by this we can get the firmware dump capability [enable/disable] via ethtool
> 
> Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
>  include/linux/ethtool.h |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 89d68d8..fea2ac0 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -661,12 +661,17 @@ struct ethtool_flash {
>   * 	%ETHTOOL_SET_DUMP
>   * @version: FW version of the dump, filled in by driver
>   * @flag: driver dependent flag for dump setting, filled in by driver during
> - * 	  get and filled in by ethtool for set operation
> + *        get and filled in by ethtool for set operation.
> + *        flag must be initialized by macro ETH_FW_DUMP_DISABLE value when
> + *        firmware dump is disabled.
>   * @len: length of dump data, used as the length of the user buffer on entry to
>   * 	 %ETHTOOL_GET_DUMP_DATA and this is returned as dump length by driver
>   * 	 for %ETHTOOL_GET_DUMP_FLAG command
>   * @data: data collected for get dump data operation
>   */
> +
> +#define ETH_FW_DUMP_DISABLE 0
> +
>  struct ethtool_dump {
>  	__u32	cmd;
>  	__u32	version;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
