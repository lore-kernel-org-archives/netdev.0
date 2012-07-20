From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Fri, 20 Jul 2012 05:21:45 +0200
Message-ID: <5008CEC9.2050908@omicron.at>
References: <20120720120118.465056f267ab5c3ac5ea45c4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Neuling <mikey@neuling.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120720120118.465056f267ab5c3ac5ea45c4@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Sent again due to problems with email client]

Hi,

On 07/20/2012 04:01 AM, Stephen Rothwell wrote:
> Hi all,
>
> After merging the net-next tree, today's linux-next build (powerpc
> pmac32_defconfig) failed like this:
>
> ERROR: "phy_disconnect" [drivers/net/usb/asix.ko] undefined!
> ERROR: "phy_stop" [drivers/net/usb/asix.ko] undefined!
> ERROR: "phy_ethtool_gset" [drivers/net/usb/asix.ko] undefined!
> ERROR: "mdiobus_unregister" [drivers/net/usb/asix.ko] undefined!
> ERROR: "phy_start_aneg" [drivers/net/usb/asix.ko] undefined!
> ERROR: "phy_print_status" [drivers/net/usb/asix.ko] undefined!
> ERROR: "phy_start" [drivers/net/usb/asix.ko] undefined!
> ERROR: "mdiobus_free" [drivers/net/usb/asix.ko] undefined!
> ERROR: "mdiobus_register" [drivers/net/usb/asix.ko] undefined!
> ERROR: "genphy_resume" [drivers/net/usb/asix.ko] undefined!
> ERROR: "phy_connect" [drivers/net/usb/asix.ko] undefined!
> ERROR: "phy_mii_ioctl" [drivers/net/usb/asix.ko] undefined!
> ERROR: "phy_ethtool_sset" [drivers/net/usb/asix.ko] undefined!
> ERROR: "mdiobus_alloc_size" [drivers/net/usb/asix.ko] undefined!
>
> Caused by commit 16626b0cc3d5 ("asix: Add a new driver for the AX88172A")
> and reverting that commit fixes the build.

Sorry about that. I missed the dependency of the new driver on phylib. A 
fix for this problem is already in net-next, see commit 215029375c83.

Thanks, Christian

>
> Thanks to Mikey for reporting this porblem.
