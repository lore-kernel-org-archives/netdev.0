From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] sh: sh_eth: Add support ethtool
Date: Tue, 11 Jan 2011 07:49:14 -0800
Message-ID: <20110111074914.60915b2b@s6510>
References: <1294747109-11511-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	yoshihiro.shimoda.uh@renesas.com, bhutchings@solarflare.com
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1294747109-11511-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Jan 2011 20:58:29 +0900
nobuhiro.iwamatsu.yj@renesas.com wrote:

> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> 
> This commit supports following functions.
>  - get_drvinfo
>  - get_settings
>  - set_settings
>  - nway_reset
>  - get_msglevel
>  - set_msglevel
>  - get_link
>  - get_strings
>  - get_ethtool_stats
>  - get_sset_count
> 
> About other function, the device does not support.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

I agree with Eric, the statistics interface is not necessary if all
the statistics are only the standard values.  The netdev stats are available
through several other interfaces already.

It would be nice to allow configuring the ring sizes.
