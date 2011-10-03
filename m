From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH net-next] drivers/net: Add module.h to wireless/ath/ath6kl/sdio.c
Date: Mon, 3 Oct 2011 13:48:33 +0300
Message-ID: <4E899301.8040808@qca.qualcomm.com>
References: <1317424079-31793-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1317424079-31793-1-git-send-email-paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/01/2011 02:07 AM, Paul Gortmaker wrote:
> This file uses various MODULE_* macros, and so needs the full
> module.h header called out explicitly.

FWIW last week I added a similar patch to ath6kl.git (but not the same
as the file has changed):

https://github.com/kvalo/ath6kl/commit/c6efe578fc5dd02463d2ee20343494da56bdd3a9

I also sent a pull request to John so it should be in wireless-next soon.

Kalle
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
