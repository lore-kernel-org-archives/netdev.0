From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: Coalesce pr_cont uses and fix
 DP typos
Date: Tue, 9 Aug 2011 17:41:23 +0300
Message-ID: <1312900883.31417.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <cover.1312818707.git.joe@perches.com>
 <98d09e1b3d7a73bf5f2744f0ca238321573e4579.1312818707.git.joe@perches.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <98d09e1b3d7a73bf5f2744f0ca238321573e4579.1312818707.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-08-08 at 08:53 -0700, Joe Perches wrote:
> Uses of pr_cont should be avoided where reasonably possible
> because they can be interleaved by other threads and processes.
> 
> Coalesce pr_cont uses.
> 
> Fix typos, duplicated words and spacing in DP uses caused
> by split multi-line formats.  Coalesce some of these
> split formats.  Add missing terminating newlines to DP uses.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---

....

> @@ -12254,7 +12261,7 @@ void bnx2x_period_func(struct link_params *params, struct link_vars *vars)
>  {
>         struct bnx2x *bp = params->bp;
>         if (!params) {
> -               DP(NETIF_MSG_LINK, "Ininitliazed params !\n");
> +               DP(NETIF_MSG_LINK, "Uninitialized params !\n");
>                 return;
>         }
>         /* DP(NETIF_MSG_LINK, "Periodic called vars->phy_flags 0x%x speed 0x%x

This does not apply on the current net-next. Other than that - it looks
good.

Please re-submit this patch series once net-next is opened for driver
changes (see: http://marc.info/?l=linux-netdev&m=131278578427946&w=2 )
and I will ACK it.

Thanks,
Eilon
