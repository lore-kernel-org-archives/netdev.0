From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 4/5] r8169: ethtool message level control
Date: Wed, 09 Mar 2005 14:50:10 -0500
Message-ID: <422F5372.8070308@pobox.com>
References: <20050309113402.05d25e49@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050309113402.05d25e49@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Add ethtool message level control support. This is the standard way
> to enable/disable console log messages.  Also, ratelimit the too much
> work at interrupt message, so if under massive packet load the console
> doesn't get flooded.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
> --- a/drivers/net/r8169.c	2005-03-09 11:25:04 -08:00
> +++ b/drivers/net/r8169.c	2005-03-09 11:25:04 -08:00
> @@ -188,6 +188,9 @@
>  MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
>  
>  static int rx_copybreak = 200;
> +static int debug = 3;
> +static const u32 default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE | 
> +			       NETIF_MSG_LINK | NETIF_MSG_IFUP| NETIF_MSG_IFDOWN;

whitespace breakage?
