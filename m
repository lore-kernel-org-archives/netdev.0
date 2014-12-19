From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet adapters
Date: Fri, 19 Dec 2014 23:04:13 +0100
Message-ID: <5494A0DD.1010304@gmx.de>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com> <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:63966 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbaLSWES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 17:04:18 -0500
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.12.2014 04:25, Raghu Vatsavayi wrote:
> +static void cn6xxx_disable_interrupt(void *chip)
> +{
> +	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)chip;
> +
> +	/* Disable Interrupts */
> +	writeq(0, cn6xxx->intr_enb_reg64);
> +}
> +

This could also be a good candidate for forced write posting. The code
assumes that interrupts are actually deactivated after that.

Regards,
Lino
