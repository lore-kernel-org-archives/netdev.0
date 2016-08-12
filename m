From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V2 02/18] liquidio: Firmware version management
Date: Fri, 12 Aug 2016 12:24:41 -0700
Message-ID: <1471029881.18251.9.camel@perches.com>
References: <1471026035-15323-1-git-send-email-rvatsavayi@caviumnetworks.com>
	 <1471026035-15323-3-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0101.hostedemail.com ([216.40.44.101]:58130 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751652AbcHLTYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 15:24:45 -0400
In-Reply-To: <1471026035-15323-3-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-08-12 at 11:20 -0700, Raghu Vatsavayi wrote:
> This patch contains changes for firmware version management.

trivial note:

> diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
[]
> @@ -30,10 +30,26 @@
>  
>  #include "octeon_config.h"
>  
> -#define LIQUIDIO_BASE_VERSION   "1.4"
> -#define LIQUIDIO_MICRO_VERSION  ".1"
>  #define LIQUIDIO_PACKAGE ""
> -#define LIQUIDIO_VERSION  "1.4.1"
> +#define LIO_STR_HELPER(x)	#x
> +#define LIO_STR(x)	LIO_STR_HELPER(x)

__stringify
