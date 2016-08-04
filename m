From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next  02/18] liquidio support for new device cn23xx
Date: Thu, 4 Aug 2016 18:12:56 +0000
Message-ID: <CO2PR11MB0088EF589259501F4BE5970497070@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <1470250549-10993-3-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0105.outbound.protection.outlook.com ([104.47.37.105]:5815
	"EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933971AbcHDSaW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 14:30:22 -0400
In-Reply-To: <1470250549-10993-3-git-send-email-rvatsavayi@caviumnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +		vdata->major =
> cpu_to_be16(LIQUIDIO_BASE_MAJOR_VERSION);
> +		vdata->minor =
> cpu_to_be16(LIQUIDIO_BASE_MINOR_VERSION);
> +		vdata->micro =
> cpu_to_be16(LIQUIDIO_BASE_MICRO_VERSION);
Will probably add sparse warnings.

> +#define LIO_STR_HELPER(x)	#x
> +#define LIO_STR(x)	LIO_STR_HELPER(x)
This is basically __stringify()

> +struct lio_version {
> +	u64  major:16;
> +	u64  minor:16;
> +	u64  micro:16;
> +	u64  reserved:16;
> +};
You probably want those typed, not merely bits out of u64.
But even if you didn't, what's the benefit this has over u16s?
