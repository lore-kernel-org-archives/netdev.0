From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm:he - Change 0 to false for bool type variable
 initialization.
Date: Tue, 26 May 2015 20:10:24 -0700 (PDT)
Message-ID: <20150526.201024.2160151638349157229.davem@davemloft.net>
References: <1432689618-3046-1-git-send-email-shailendra.capricorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shailendra.capricorn@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432689618-3046-1-git-send-email-shailendra.capricorn@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shailendra Verma <shailendra.capricorn@gmail.com>
Date: Wed, 27 May 2015 06:50:18 +0530

> The variable sdh is bool type so initializing it with false value
> instead of 0.
> 
> Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>
> ---
>  drivers/atm/he.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/atm/he.c b/drivers/atm/he.c
> index 93dca2e..eb5bebc 100644
> --- a/drivers/atm/he.c
> +++ b/drivers/atm/he.c
> @@ -116,8 +116,8 @@ static bool disable64;
>  static short nvpibits = -1;
>  static short nvcibits = -1;
>  static short rx_skb_reserve = 16;
> -static bool irq_coalesce = 1;
> -static bool sdh = 0;
> +static bool irq_coalesce = true;
> +static bool sdh = false;

You didn't understand my feedback.

I already applied your patch that handled the irq_coalesce issue,
so you have to submit a patch relative to that.

In fact, you should always test that your patch applied to my tree
before submitting it.
