From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next 8/8] net: qualcomm: add QCA7000 UART driver
Date: Tue, 20 Sep 2016 17:32:36 +0200
Message-ID: <2EE064FD-FCC1-4559-819D-471BD000F5AF@holtmann.org>
References: <1474376544-20515-1-git-send-email-stefan.wahren@i2se.com> <1474376544-20515-9-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Rob Herring <robh@kernel.org>
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474376544-20515-9-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stefan,

> This patch adds the Ethernet over UART driver for the
> Qualcomm QCA7000 HomePlug GreenPHY.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> ---
> drivers/net/ethernet/qualcomm/Kconfig      |  12 +
> drivers/net/ethernet/qualcomm/Makefile     |   2 +
> drivers/net/ethernet/qualcomm/qca_common.h |   6 +
> drivers/net/ethernet/qualcomm/qca_uart.c   | 447 +++++++++++++++++++++++++++++
> include/uapi/linux/tty.h                   |   1 +
> 5 files changed, 468 insertions(+)
> create mode 100644 drivers/net/ethernet/qualcomm/qca_uart.c
> 
> diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
> index 0d33728..0ede46e 100644
> --- a/drivers/net/ethernet/qualcomm/Kconfig
> +++ b/drivers/net/ethernet/qualcomm/Kconfig
> @@ -30,6 +30,18 @@ config QCA7000_SPI
> 	  To compile this driver as a module, choose M here. The module
> 	  will be called qcaspi.
> 
> +config QCA7000_UART
> +	tristate "Qualcomm Atheros QCA7000 UART support"
> +	select QCA7000
> +	depends on TTY
> +	---help---
> +	  This UART protocol driver supports the Qualcomm Atheros QCA7000.
> +	  The driver implements the tty line discipline N_QCA7K and supports
> +	  only one netdevice.
> +
> +	  To compile this driver as a module, choose M here. The module
> +	  will be called qcauart.
> +

this seems to be another candidate for having a proper UART or serial bus. Instead of adding one line discipline after another, I think we need to get quickly to having an enumerable bus here.

Regards

Marcel
