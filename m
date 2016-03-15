From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH] net: ena: Add a driver for Amazon Elastic Network
 Adapters (ENA)
Date: Tue, 15 Mar 2016 08:25:50 -0700
Message-ID: <20160315152548.GA18677@u54ee753d2d1854bda401.ant.amazon.com>
References: <1458039006-19956-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zorik@annapurnalabs.com, saeed@annapurnalabs.com,
	alex@annapurnalabs.com, aliguori@amazon.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	antoine.tenart@free-electrons.com
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1458039006-19956-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Netanel,

Looks like the last round of internal review went to {lkml,netdev,etc},
so this should be considered a RFC patch.

The description still needs work.

On Tue, Mar 15, 2016 at 12:50:06PM +0200, Netanel Belgazal wrote:
> This is a driver for the Amazon ethernet ENA family.

ethernet -> Ethernet

> The driver operates variety of ENA adapters through
> feature negotiation with the adapter and upgradable commands set.
> ENA driver handles PCI Physical and Virtual ENA functions.
> 
> The ENA device is not yet released to public.
> He is expected to be released soon.

I would say "this is a driver for a device that will be available in
the future." I wouldn't say "He is expected to released soon."

> For the full specification of the device please refer to:
> <SPEC-PATH>

Obviously this is a placeholder. I think that the included
documentation in ena.txt and in the code provides a reasonable theory
of operation, and you don't necessarily need to provide a pointer
here. If/when a full specification is available you can submit a patch
to ena.txt that points to the canonical location.

--msw

> ---
>  Documentation/networking/00-INDEX                 |    2 +
>  Documentation/networking/ena.txt                  |  330 +++
>  MAINTAINERS                                       |    9 +
>  drivers/net/ethernet/Kconfig                      |    1 +
>  drivers/net/ethernet/Makefile                     |    1 +
>  drivers/net/ethernet/amazon/Kconfig               |   27 +
>  drivers/net/ethernet/amazon/Makefile              |    5 +
>  drivers/net/ethernet/amazon/ena/Makefile          |    9 +
>  drivers/net/ethernet/amazon/ena/ena_admin_defs.h  | 1310 +++++++++
>  drivers/net/ethernet/amazon/ena/ena_com.c         | 2730 ++++++++++++++++++
>  drivers/net/ethernet/amazon/ena/ena_com.h         | 1040 +++++++
>  drivers/net/ethernet/amazon/ena/ena_common_defs.h |   52 +
>  drivers/net/ethernet/amazon/ena/ena_eth_com.c     |  502 ++++
>  drivers/net/ethernet/amazon/ena/ena_eth_com.h     |  146 +
>  drivers/net/ethernet/amazon/ena/ena_eth_io_defs.h |  509 ++++
>  drivers/net/ethernet/amazon/ena/ena_ethtool.c     |  837 ++++++
>  drivers/net/ethernet/amazon/ena/ena_netdev.c      | 3179 +++++++++++++++++++++
>  drivers/net/ethernet/amazon/ena/ena_netdev.h      |  317 ++
>  drivers/net/ethernet/amazon/ena/ena_pci_id_tbl.h  |   77 +
>  drivers/net/ethernet/amazon/ena/ena_regs_defs.h   |  133 +
>  drivers/net/ethernet/amazon/ena/ena_sysfs.c       |  272 ++
>  drivers/net/ethernet/amazon/ena/ena_sysfs.h       |   55 +
[...]
