From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2.6.20] e1000: Use ARRAY_SIZE macro when appropriate
Date: Tue, 06 Feb 2007 09:16:56 -0800
Message-ID: <45C8B808.3080908@intel.com>
References: <20070205165546.GE3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cramerj@intel.com, john.ronciak@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13330 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932952AbXBFRRH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 12:17:07 -0500
In-Reply-To: <20070205165546.GE3896@Ahmed>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ahmed S. Darwish wrote:
> Hi,
> 
> A patch to use ARRAY_SIZE macro already defined in kernel.h.
> 
> Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>

Acked-by: Auke Kok <auke-jan.h.kok@intel.com>

Cheers,

Auke

> ---
> Patch is compile tested.
> 
> diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
> index fb96c87..d21706e 100644
> --- a/drivers/net/e1000/e1000_ethtool.c
> +++ b/drivers/net/e1000/e1000_ethtool.c
> @@ -746,7 +746,7 @@ err_setup:
>  	uint32_t pat, value;                                                   \
>  	uint32_t test[] =                                                      \
>  		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};              \
> -	for (pat = 0; pat < sizeof(test)/sizeof(test[0]); pat++) {              \
> +	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {              \
>  		E1000_WRITE_REG(&adapter->hw, R, (test[pat] & W));             \
>  		value = E1000_READ_REG(&adapter->hw, R);                       \
>  		if (value != (test[pat] & W & M)) {                             \
> 
