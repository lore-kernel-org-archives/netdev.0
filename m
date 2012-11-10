From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH 02/10] arm: at91: move platfarm_data to include/linux/platform_data/atmel.h
Date: Sat, 10 Nov 2012 11:54:27 +0100
Message-ID: <CAGhQ9VxgbCGzOPVtQq-LYsEPuyyGjRDfB3jHPtvbHr1xLgntXA@mail.gmail.com>
References: <20121107111235.GH20063@game.jcrosoft.org>
	<1352287374-25176-1-git-send-email-plagnioj@jcrosoft.com>
	<1352287374-25176-2-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-arm-kernel@lists.infradead.org, linux-fbdev@vger.kernel.org,
	linux-usb@vger.kernel.org, rtc-linux@googlegroups.com,
	linux-mmc@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-can@vger.kernel.org, linux-ide@vger.kernel.org,
	netdev@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-input@vger.kernel.org,
	spi-devel-general@lists.sourceforge.net
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1352287374-25176-2-git-send-email-plagnioj@jcrosoft.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jean-Christophe,

On 7 November 2012 12:22, Jean-Christophe PLAGNIOL-VILLARD
<plagnioj@jcrosoft.com> wrote:
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: linux-ide@vger.kernel.org
> Cc: linux-input@vger.kernel.org
> Cc: linux-mmc@vger.kernel.org
> Cc: linux-can@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: linux-pcmcia@lists.infradead.org
> Cc: rtc-linux@googlegroups.com
> Cc: spi-devel-general@lists.sourceforge.net
> Cc: linux-serial@vger.kernel.org
> Cc: linux-usb@vger.kernel.org
> Cc: linux-fbdev@vger.kernel.org
> ---
> HI all,
>
>         If it's ok with everyone this will go via at91
>         with the patch serie than clean up the include/mach
>
>         For preparation to switch to arm multiarch kernel
>
> Best Regards,
> J.
>  arch/arm/mach-at91/include/mach/board.h     |   55 ----------------------
>  arch/avr32/mach-at32ap/include/mach/board.h |    7 ---
>  drivers/ata/pata_at91.c                     |    2 +-
>  drivers/input/touchscreen/atmel_tsadcc.c    |    2 +-
>  drivers/mmc/host/atmel-mci.c                |    2 +-
>  drivers/net/can/at91_can.c                  |    3 +-
>  drivers/net/ethernet/cadence/at91_ether.c   |    2 +-
>  drivers/pcmcia/at91_cf.c                    |    2 +-
>  drivers/rtc/rtc-at91sam9.c                  |    2 +-
>  drivers/spi/spi-atmel.c                     |    2 +-
>  drivers/tty/serial/atmel_serial.c           |    2 +-
>  drivers/usb/gadget/at91_udc.c               |    2 +-
>  drivers/usb/gadget/atmel_usba_udc.c         |    2 +-
>  drivers/usb/host/ohci-at91.c                |    2 +-
>  drivers/video/atmel_lcdfb.c                 |    2 +-
>  include/linux/platform_data/atmel.h         |   67 +++++++++++++++++++++++++++
>  16 files changed, 80 insertions(+), 76 deletions(-)

<snip>

> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
> index 4e980a7..35fc6edb 100644
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ b/drivers/net/ethernet/cadence/at91_ether.c
> @@ -31,6 +31,7 @@
>  #include <linux/clk.h>
>  #include <linux/gfp.h>
>  #include <linux/phy.h>
> +#include <linux/platform_data/atmel.h>
>
>  #include <asm/io.h>
>  #include <asm/uaccess.h>
> @@ -38,7 +39,6 @@
>
>  #include <mach/at91rm9200_emac.h>
>  #include <asm/gpio.h>
> -#include <mach/board.h>
>
>  #include "at91_ether.h"

The at91_ether driver in net-next does not need to be change since it
all mach includes has already been removed by other patches and it
includes linux/platform_data/macb.h directly.

What tree was these patches based on?
The at91_ether driver changes has been in linux-next for a long while now.

regards
Joachim Eastwood
