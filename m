From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V2 02/10] liquidio: Macro replacements
Date: Sun, 03 Jul 2016 15:17:00 -0700
Message-ID: <1467584220.1968.12.camel@perches.com>
References: <1467579416-24219-1-git-send-email-rvatsavayi@caviumnetworks.com>
	 <1467579416-24219-3-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0018.hostedemail.com ([216.40.44.18]:38866 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932160AbcGCWRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 18:17:04 -0400
In-Reply-To: <1467579416-24219-3-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-07-03 at 13:56 -0700, Raghu Vatsavayi wrote:
> This patch has minor replacements of ACCESS_ONCE macros with
> WRITE_ONCE and replacement of BUG_ON with polite version WARN_ON.

And makes some functions static.
> diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/d=
rivers/net/ethernet/cavium/liquidio/cn66xx_device.c
[]
> @@ -547,14 +537,14 @@ static void lio_cn6xxx_get_pcie_qlmport(struct =
octeon_device *oct)
> =A0	dev_dbg(&oct->pci_dev->dev, "Using PCIE Port %d\n", oct->pcie_por=
t);
> =A0}
> =A0
> -void
> +static void
[]
> -int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *oct)
> +static int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *o=
ct)

etc
