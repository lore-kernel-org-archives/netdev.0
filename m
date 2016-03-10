From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: Fix cleanup resources upon module removal
Date: Thu, 10 Mar 2016 16:21:01 -0500 (EST)
Message-ID: <20160310.162101.2164001740647971703.davem@davemloft.net>
References: <20151207.163608.1805578623951785262.davem@davemloft.net>
	<1457429780-7665-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, rmk+kernel@arm.linux.org.uk,
	pavel.nakonechny@skitlab.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: narmstrong@baylibre.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457429780-7665-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Armstrong <narmstrong@baylibre.com>
Date: Tue,  8 Mar 2016 10:36:20 +0100

> The initial commit badly merged into the dsa_resume method instead
> of the dsa_remove_dst method.
> As consequence, the dst->master_netdev->dsa_ptr is not set to NULL on
> removal and re-bind of the dsa device fails with error -17.
> 
> Fixes: b0dc635d923c ("net: dsa: cleanup resources upon module removal ")
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  net/dsa/dsa.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> David, Florian, Andrew,
> 
> This fix is quite urgent since it breaks all the removal cleanup.

Since 'net' is closed, I've applied this to 'net-next' and queue it up for
-stable.

Thanks.
