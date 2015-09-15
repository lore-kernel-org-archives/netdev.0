From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-next PATCH v3] drivers: net: cpsw: Add support to drive
 gpios for ethernet to be functional
Date: Tue, 15 Sep 2015 12:38:15 -0700 (PDT)
Message-ID: <20150915.123815.1848038420469146072.davem@davemloft.net>
References: <1441619204-15403-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org,
	linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mugunthanvnm-l0cyMroinI0@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1441619204-15403-1-git-send-email-mugunthanvnm-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Date: Mon, 7 Sep 2015 15:16:44 +0530

> In DRA72x EVM, by default slave 1 is connected to the onboard
> phy, but slave 2 pins are also muxed with video input module
> which is controlled by pcf857x gpio and currently to select slave
> 0 to connect to phy gpio hogging is used, but with
> omap2plus_defconfig the pcf857x gpio is built as module. So when
> using NFS on DRA72x EVM, board doesn't boot as gpio hogging do
> not set proper gpio state to connect slave 0 to phy as it is
> built as module and you do not see any errors for not setting
> gpio and just mentions dhcp reply not got.
> 
> To solve this issue, introducing "mode-gpios" in DT when gpio
> based muxing is required. This will throw a warning when gpio
> get fails and returns probe defer. When gpio-pcf857x module is
> installed, cpsw probes again and ethernet becomes functional.
> Verified this on DRA72x with pcf as module and ramdisk.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
