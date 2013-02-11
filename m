From: Luciano Coelho <coelho@ti.com>
Subject: Re: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Mon, 11 Feb 2013 08:47:54 +0200
Message-ID: <1360565274.12803.45.camel@cumari.coelho.fi>
References: <20130211133350.5f510bbb28759960a19a98af@canb.auug.org.au>
	 <1360551527.2028.10.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1360551527.2028.10.camel@joe-AO722>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-02-10 at 18:58 -0800, Joe Perches wrote:
> On Mon, 2013-02-11 at 13:33 +1100, Stephen Rothwell wrote:
> > Hi John,
> > 
> > Today's linux-next merge of the wireless-next tree got conflicts in
> > drivers/net/wireless/ti/wlcore/sdio.c and
> > drivers/net/wireless/ti/wlcore/spi.c between commit 0d2e7a5c6080
> > ("wireless: Remove unnecessary alloc/OOM messages, alloc cleanups") from
> > the net-next tree and commit afb43e6d88e5 ("wlcore: remove if_ops from
> > platform_data") from the wireless-next tree.
> > 
> > I fixed it up (see below) and can carry the fix as necessary (no action
> > is required).
> > 

The fix up looks good.  Thanks!


> Thanks Stephen.
> 
> Can you remove just the dev_err below too please.
> 
> +       pdev_data = kzalloc(sizeof(*pdev_data), GFP_KERNEL);
> +       if (!pdev_data) {
> +               dev_err(&func->dev, "can't allocate platdev_data\n");
> +               goto out;
> +       }

Yes, and there's also another one in
drivers/net/wireless/ti/wlcore/spi.c:

+       pdev_data = kzalloc(sizeof(*pdev_data), GFP_KERNEL);
+       if (!pdev_data) {
+               dev_err(&spi->dev, "can't allocate platdev_data\n");
+               goto out;
+       }

--
Cheers,
Luca.
