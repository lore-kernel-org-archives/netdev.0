From: "Valo, Kalle" <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH V2 2/2] ath6kl: replace semaphore with mutex
Date: Wed, 22 Jun 2016 08:59:59 +0000
Message-ID: <87h9cliooi.fsf@kamboji.qca.qualcomm.com>
References: <20160621232210.5801-1-chaehyun.lim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ath6kl-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <ath6kl-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Chaehyun Lim <chaehyun.lim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160621232210.5801-1-chaehyun.lim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Chaehyun Lim's
	message of "Wed, 22 Jun 2016 08:22:10 +0900")
Content-Language: en-US
Content-ID: <5D0D1FB8CA851F48A1830A30AF07B73F-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(Adding ath6k list)

Chaehyun Lim <chaehyun.lim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> It replaces struct semaphore sem with struct mutex mutex
>
> Reported-by: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Chaehyun Lim <chaehyun.lim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> V2: fix build failure reported by kbuild test robot

I don't think Reported-by is correct, it should be only used when
reporting the original issue

Have you tested this on a real device? I'm reluctant to apply this big
locking change without some level of testing.

-- 
Kalle Valo--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
