From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next v2 1/6] bnx2x: link report improvements
Date: Wed, 04 May 2011 23:48:29 +0100
Message-ID: <1304549309.2926.84.camel@bwh-desktop>
References: <1304547764.19742.17.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40019 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756145Ab1EDWsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 18:48:32 -0400
In-Reply-To: <1304547764.19742.17.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-05 at 01:22 +0300, Dmitry Kravkov wrote:
> From: Vladislav Zolotarov <vladz@broadcom.com>
> 
> To avoid link notification duplication
[...]
> --- a/drivers/net/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> @@ -758,35 +758,120 @@ u16 bnx2x_get_mf_speed(struct bnx2x *bp)
>  	return line_speed;
>  }
>  
> +/**
> + * bnx2x_fill_report_data - fill Link report data according to the current link
> + * configuration.

The kernel-doc format doesn't allow for continuation lines like this.
The short description has to fit on one physical line along with the
function or type name.

Ben.

> + * @bp:		driver handle
> + * @data:	link state to update
> + *
> + * It uses a none-atomic bit operations because is called under the mutex.
> + */
[...]

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

