From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH V2 1/3] bluetooth: Add logging functions bt_info and
 bt_err
Date: Fri, 17 Feb 2012 09:37:39 +0100
Message-ID: <1329467859.28848.130.camel@aeonflux>
References: <cover.1329461202.git.joe@perches.com>
	 <5c5e8180081e57e6098139fadd9275073048f448.1329461203.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5c5e8180081e57e6098139fadd9275073048f448.1329461203.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

> Use specific logging functions instead of a generic
> bt_printk function can save some text.
> 
> Remove now unused bt_printk function.
> Add compatibility BT_INFO and BT_ERR macros.
> 
> (compiled x86 and defconfig with bluetooth and all bluetooth drivers)
> 
> $ size net/bluetooth/built-in.o*
>    text	   data	    bss	    dec	    hex	filename
>  381662	  20072	 100416	 502150	  7a986	net/bluetooth/built-in.o.allyesconfig.new
>  382463	  20072	 100400	 502935	  7ac97	net/bluetooth/built-in.o.allyesconfig.old
>  126635	   1388	    132	 128155	  1f49b	net/bluetooth/built-in.o.defconfig.new
>  127175	   1388	    132	 128695	  1f6b7	net/bluetooth/built-in.o.defconfig.old
> 
> $ size drivers/bluetooth/built-in.o*
>  127575	   8976	  29476	 166027	  2888b	drivers/bluetooth/built-in.o.allyesconfig.new
>  129512	   8976	  29516	 168004	  29044	drivers/bluetooth/built-in.o.allyesconfig.old
>   52998	   3292	    156	  56446	   dc7e	drivers/bluetooth/built-in.o.defconfig.new
>   54358	   3292	    156	  57806	   e1ce	drivers/bluetooth/built-in.o.defconfig.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  include/net/bluetooth/bluetooth.h |   14 ++++++++------
>  net/bluetooth/lib.c               |   27 ++++++++++++++++++++++++---
>  2 files changed, 32 insertions(+), 9 deletions(-)

lets try to get at least this patch merged. I hope we don't have too
many conflicts.

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel
