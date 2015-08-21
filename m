From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] lib/Makefile: remove CONFIG_AVERAGE build rule
Date: Fri, 21 Aug 2015 12:13:23 +0200
Message-ID: <1440152003.2107.12.camel@sipsolutions.net>
References: <1440151514-5796-1-git-send-email-valentinrothberg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Valentin Rothberg <valentinrothberg@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440151514-5796-1-git-send-email-valentinrothberg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-08-21 at 10:05 +0000, Valentin Rothberg wrote:
> The Kconfig option AVERAGE and its implementation has been removed by
> commit f4e774f55fe0 ("average: remove out-of-line implementation").
> Remove the dead build rule in lib/Makefile.

D'oh, sorry about that.

Reviewed-by: Johannes Berg <johannes@sipsolutions.net>

[reproducing patch in full for netdev]

> Signed-off-by: Valentin Rothberg <valentinrothberg@gmail.com>
> ---
> I detected the issue with scripts/checkkconfigsymbols.py
> 
>  lib/Makefile | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/lib/Makefile b/lib/Makefile
> index 51e1d761f0b9..f32d342b75de 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -143,8 +143,6 @@ obj-$(CONFIG_GENERIC_ATOMIC64) += atomic64.o
> 
>  obj-$(CONFIG_ATOMIC64_SELFTEST) += atomic64_test.o
> 
> -obj-$(CONFIG_AVERAGE) += average.o
> -
>  obj-$(CONFIG_CPU_RMAP) += cpu_rmap.o
> 
>  obj-$(CONFIG_CORDIC) += cordic.o
> --
> 1.9.1
> 
