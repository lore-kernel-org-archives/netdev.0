From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding:update xmit_hash_policy description
Date: Wed, 25 May 2011 10:40:37 -0400
Message-ID: <20110525144036.GJ21309@gospo.rdu.redhat.com>
References: <1306317904-18740-1-git-send-email-panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jpirko@redhat.com, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"open list:BONDING DRIVER" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1306317904-18740-1-git-send-email-panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 25, 2011 at 06:05:04PM +0800, Weiping Pan wrote:
> xmit_hash_policy supports layer2+3 now,
> and both balance-xor and 802.3ad use xmit_hash_policy.
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>
> ---
>  drivers/net/bonding/bond_main.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 088fd84..d1f5606 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -147,8 +147,7 @@ MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner "
>  module_param(ad_select, charp, 0);
>  MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic: stable (0, default), bandwidth (1), count (2)");
>  module_param(xmit_hash_policy, charp, 0);
> -MODULE_PARM_DESC(xmit_hash_policy, "XOR hashing method: 0 for layer 2 (default)"
> -				   ", 1 for layer 3+4");
> +MODULE_PARM_DESC(xmit_hash_policy, "balance-xor and 802.3ad hashing method: 0 for layer 2 (default), 1 for layer 3+4, 2 for layer 2+3");

This is a good idea and a definite bug-fix.  Thanks for posting it.

I do not want to create a description that is longer than 80 characters
in the source if I can help it.  I went ahead and cleaned up all the
descriptions and have posted a followup patch.
