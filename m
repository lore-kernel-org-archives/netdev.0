From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] 6lowpan: Allow 6LoWPAN to be modular
Date: Thu, 7 Aug 2014 09:00:36 -0700
Message-ID: <ABE15994-F47B-4E4B-A6FC-79C6BCAC9FF3@holtmann.org>
References: <1407424003-15073-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Alexander Aring <alex.aring@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407424003-15073-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geert,

> Change config symbol 6LOWPAN from type bool to type tristate, so
> 6LoWPAN can be built modular, just like IPV6
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> net/6lowpan/Kconfig | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
> index 028a5c6d1f61..e4a02ef55102 100644
> --- a/net/6lowpan/Kconfig
> +++ b/net/6lowpan/Kconfig
> @@ -1,5 +1,5 @@
> config 6LOWPAN
> -	bool "6LoWPAN Support"
> +	tristate "6LoWPAN Support"

is this a regression from the previous CONFIG_6LOWPAN separation that we introduced? If it is, then it might be easiest if Dave just takes it into his net tree. Otherwise I take it through bluetooth-next.

Regards

Marcel
