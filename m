From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Mon, 13 Jun 2016 13:36:54 -0700
Message-ID: <20160613203653.GA23290@u54ee753d2d1854bda401.ant.amazon.com>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davm@davemeloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com,
	aliguori@amazon.com, antoine.tenart@free-electrons.com
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2016 at 11:46:13AM +0300, Netanel Belgazal wrote:
> This is a driver for the forthcoming ENA family of networking devices.

Reviewed-by: Matt Wilson <msw@amazon.com>

> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> ---
>  Documentation/networking/00-INDEX                 |    2 +
>  Documentation/networking/ena.txt                  |  330 ++
>  MAINTAINERS                                       |    9 +
>  drivers/net/ethernet/Kconfig                      |    1 +
>  drivers/net/ethernet/Makefile                     |    1 +
>  drivers/net/ethernet/amazon/Kconfig               |   27 +
>  drivers/net/ethernet/amazon/Makefile              |    5 +
>  drivers/net/ethernet/amazon/ena/Makefile          |    9 +
>  drivers/net/ethernet/amazon/ena/ena_admin_defs.h  | 1246 ++++++++
>  drivers/net/ethernet/amazon/ena/ena_com.c         | 2768 +++++++++++++++++
>  drivers/net/ethernet/amazon/ena/ena_com.h         | 1051 +++++++
>  drivers/net/ethernet/amazon/ena/ena_common_defs.h |   52 +
>  drivers/net/ethernet/amazon/ena/ena_eth_com.c     |  508 ++++
>  drivers/net/ethernet/amazon/ena/ena_eth_com.h     |  160 +
>  drivers/net/ethernet/amazon/ena/ena_eth_io_defs.h |  460 +++
>  drivers/net/ethernet/amazon/ena/ena_ethtool.c     |  836 +++++
>  drivers/net/ethernet/amazon/ena/ena_netdev.c      | 3362 +++++++++++++++++++++
>  drivers/net/ethernet/amazon/ena/ena_netdev.h      |  327 ++
>  drivers/net/ethernet/amazon/ena/ena_pci_id_tbl.h  |   67 +
>  drivers/net/ethernet/amazon/ena/ena_regs_defs.h   |  133 +
>  drivers/net/ethernet/amazon/ena/ena_sysfs.c       |  264 ++
>  drivers/net/ethernet/amazon/ena/ena_sysfs.h       |   55 +
>  22 files changed, 11673 insertions(+)
>  create mode 100644 Documentation/networking/ena.txt
>  create mode 100644 drivers/net/ethernet/amazon/Kconfig
>  create mode 100644 drivers/net/ethernet/amazon/Makefile
>  create mode 100644 drivers/net/ethernet/amazon/ena/Makefile
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_admin_defs.h
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_com.c
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_com.h
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_common_defs.h
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_eth_com.c
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_eth_com.h
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_eth_io_defs.h
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_ethtool.c
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_netdev.c
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_netdev.h
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_pci_id_tbl.h
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_regs_defs.h
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_sysfs.c
>  create mode 100644 drivers/net/ethernet/amazon/ena/ena_sysfs.h

[...]

--msw
