From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] ath/ath9k/ar9003_eeprom.c: Remove unnecessary semicolon
Date: Sun, 30 Sep 2012 21:34:43 +0200
Message-ID: <1349033683.23838.6.camel@jlt4.sipsolutions.net>
References: <1349032870-4780-1-git-send-email-peter.senna@gmail.com>
	 (sfid-20120930_212132_608267_30BA39AB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, senthilb-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Peter Senna Tschudin <peter.senna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1349032870-4780-1-git-send-email-peter.senna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (sfid-20120930_212132_608267_30BA39AB)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-09-30 at 21:21 +0200, Peter Senna Tschudin wrote:

> -		if (!ah->config.enable_paprd);
> +		if (!ah->config.enable_paprd)
>  			return false;

That's not an "unnecessary semicolon", it's a pretty strange bug :)

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
