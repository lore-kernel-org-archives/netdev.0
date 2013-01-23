From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [RFC PATCH v2 linux-next] et131x: Promote staging et131x driver
 to drivers/net
Date: Wed, 23 Jan 2013 13:31:08 +0300
Message-ID: <20130123103108.GA4584@mwanda>
References: <1358541648-29922-1-git-send-email-mark.einon@gmail.com>
 <1358935859-29525-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gregkh@linuxfoundation.org,
	sfr@canb.auug.org.au, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358935859-29525-1-git-send-email-mark.einon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 23, 2013 at 10:10:58AM +0000, Mark Einon wrote:
> diff --git a/drivers/net/ethernet/agere/Kconfig b/drivers/net/ethernet/agere/Kconfig
> new file mode 100644
> index 0000000..6854966
> --- /dev/null
> +++ b/drivers/net/ethernet/agere/Kconfig
> @@ -0,0 +1,32 @@
> +#
> +# Agere device configuration
> +#
> +
> +config NET_VENDOR_AGERE
> +       bool "Agere devices"
> +       default y
> +       depends on PCI
> +       ---help---
> +         If you have a network (Ethernet) card belonging to this class, say Y
> +         and read the Ethernet-HOWTO, available from
> +         <http://www.tldp.org/docs.html#howto>.
> +
> +         Note that the answer to this question doesn't directly affect the
> +         kernel: saying N will just cause the configurator to skip all
> +         the questions about Atheros devices. If you say Y, you will be asked
                                ^^^^^^^
Agere?

> +         for your specific card in the following questions.
> +

I think you should just leave this block out entirely.  It doesn't
save time for anyone.

regards,
dan carpenter
