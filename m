From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/6] mISDN: remove unused function
Date: Sat, 24 Sep 2016 10:42:14 +0200
Message-ID: <6975809.FmUs8oxeay@wuerfel>
References: <1474694882-25427-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: isdn@linux-pingi.de, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474694882-25427-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, September 24, 2016 1:28:02 PM CEST Baoyou Xie wrote:
> diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
> index f6ab6027..2519510 100644
> --- a/drivers/isdn/mISDN/layer2.c
> +++ b/drivers/isdn/mISDN/layer2.c
> @@ -459,15 +459,6 @@ IsDISC(u_char *data)
>         return (data[0] & 0xef) == DISC;
>  }
>  
> -inline int
> -IsRR(u_char *data, struct layer2 *l2)
> -{
> -       if (test_bit(FLG_MOD128, &l2->flag))
> -               return data[0] == RR;
> -       else
> -               return (data[0] & 0xf) == 1;
> -}
> -
>  static inline int
>  IsSFrame(u_char *data, struct layer2 *l2)
>  {
> -- 
> 

This is not wrong, but it might be nicer to just
make this one as 'static inline' as well like the other
ones for consistency.

Note that static inline functions don't cause a warning
when they are unused.

	Arnd
