From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next V3 16/18] liquidio: CN23XX health monitoring
Date: Mon, 22 Aug 2016 16:53:50 +0000
Message-ID: <CO2PR11MB0088CFF57EA49EC3ED5D869697E80@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <1471824765-26473-17-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0098.outbound.protection.outlook.com ([104.47.33.98]:18896
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755830AbcHVQyA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 12:54:00 -0400
In-Reply-To: <1471824765-26473-17-git-send-email-rvatsavayi@caviumnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +				/* look at watchdog state field */
> +				wdog &=3D 12ULL;
Magic value? Probably could use a define.

> +				if (core_is_stuck[core_num] =3D=3D 1) {
> +					dev_err(&oct->pci_dev->dev,
> +						"ERROR: Octeon core %d is
> stuck!\n",
> +						core_num);
> +					core_is_stuck[core_num] =3D
> +						2; /* 2 means we have printk'd
> +						    * an error; so no need to
> +						    * repeat the same printk
> +						    */
Likewise.


> +		if (!(scratch1 & 4ULL)) {
> +			/* Bit 2 of SLI_SCRATCH_1 is a flag that indicates that
> +			 * the lio watchdog kernel thread is running for this
> +			 * NIC.  Each NIC gets one watchdog kernel thread.
> +			 */
> +			scratch1 |=3D 4ULL;
Likewise.
