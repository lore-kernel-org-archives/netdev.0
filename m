From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/4] zd1211rw: remove unnecessary [kv][mcz]alloc casts
Date: Sun, 28 Nov 2010 10:12:46 +0100
Message-ID: <1290935566.3467.0.camel@jlt3.sipsolutions.net>
References: <cover.1290934782.git.joe@perches.com>
	 <704bdd89d630b364043ac7a9ec0a110d311a17a2.1290934782.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, Ulrich Kunitz <kune@deine-taler.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <704bdd89d630b364043ac7a9ec0a110d311a17a2.1290934782.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2010-11-28 at 01:05 -0800, Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/zd1211rw/zd_chip.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
> index 87a95bc..dfcebed 100644
> --- a/drivers/net/wireless/zd1211rw/zd_chip.c
> +++ b/drivers/net/wireless/zd1211rw/zd_chip.c
> @@ -117,8 +117,7 @@ int zd_ioread32v_locked(struct zd_chip *chip, u32 *values, const zd_addr_t *addr
>  
>  	/* Allocate a single memory block for values and addresses. */
>  	count16 = 2*count;
> -	a16 = (zd_addr_t *) kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
> -		                   GFP_KERNEL);
> +	a16 = kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)), GFP_KERNEL);

I believe this is on purpose for sparse.

johannes
