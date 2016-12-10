From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: macb: Added PCI wrapper for Platform
 Driver.
Date: Fri, 09 Dec 2016 22:56:43 -0500 (EST)
Message-ID: <20161209.225643.1993365290880948769.davem@davemloft.net>
References: <SN1PR0701MB1951518D661B27AB9C63FA59CC870@SN1PR0701MB1951.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, niklas.cassel@axis.com,
        alexandre.torgue@st.com, satananda.burla@caviumnetworks.com,
        rvatsavayi@caviumnetworks.com, simon.horman@netronome.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        rafalo@cadence.com
To: bfolta@cadence.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <SN1PR0701MB1951518D661B27AB9C63FA59CC870@SN1PR0701MB1951.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bartosz Folta <bfolta@cadence.com>
Date: Fri, 9 Dec 2016 10:05:46 +0000

> There are hardware PCI implementations of Cadence GEM network controller. This patch will allow to use such hardware with reuse of existing Platform Driver.

Please properly format your commit message text to 80 columns.

> 
> Signed-off-by: Bartosz Folta <bfolta@cadence.com>
> ---
>  drivers/net/ethernet/cadence/Kconfig    |   9 ++
>  drivers/net/ethernet/cadence/Makefile   |   1 +
>  drivers/net/ethernet/cadence/macb.c     |  31 +++++--
>  drivers/net/ethernet/cadence/macb_pci.c | 152 ++++++++++++++++++++++++++++++++
>  include/linux/platform_data/macb.h      |   6 ++
>  5 files changed, 194 insertions(+), 5 deletions(-)  create mode 100644 drivers/net/ethernet/cadence/macb_pci.c

This patch doesn't apply to net-next, please respin.
