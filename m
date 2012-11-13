From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: linux-next: manual merge of the arm-soc tree with the net-next tree
Date: Tue, 13 Nov 2012 08:21:26 +0100
Message-ID: <CAGhQ9Vx3Y3j0qqkEif09HebFyR+1UYmSbp=3jwuXnoiuWBdymQ@mail.gmail.com>
References: <20121113151536.50d0292e8cb88b10686b576e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121113151536.50d0292e8cb88b10686b576e@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13 November 2012 05:15, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> Today's linux-next merge of the arm-soc tree got a conflict in
> drivers/net/ethernet/cadence/at91_ether.c between various commits from
> the net-next tree and commit bcd2360c1ff9 ("arm: at91: move platfarm_data
> to include/linux/platform_data/atmel.h") from the arm-soc tree.
>
> I fixed it up (I think - see below) and can carry the fix as necessary
> (no action is required).
>
> --
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
>
> diff --cc drivers/net/ethernet/cadence/at91_ether.c
> index e7a476c,35fc6edb..0000000
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ b/drivers/net/ethernet/cadence/at91_ether.c
> @@@ -25,53 -31,728 +25,54 @@@
>   #include <linux/clk.h>
>   #include <linux/gfp.h>
>   #include <linux/phy.h>
>  +#include <linux/io.h>
>  +#include <linux/of.h>
>  +#include <linux/of_device.h>
>  +#include <linux/of_net.h>
>  +#include <linux/pinctrl/consumer.h>
> + #include <linux/platform_data/atmel.h>

The platform_data/atmel.h include shouldn't be necessary since the
driver already includes platform_data/macb.h.

Otherwise the fix up looks correct.

regards
Joachim Eastwood
