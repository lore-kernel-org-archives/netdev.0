From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] b43: Fix a memory leak in b43_bus_dev_ssb_init
Date: Mon, 11 Jan 2016 17:42:36 +0100
Message-ID: <CACna6ryM1vekanY6WEC9g5G70uZi=rEOShgv1xamK8MuD=YsrA@mail.gmail.com>
References: <1452483457-568-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	=?UTF-8?Q?Michael_B=C3=BCsch?= <m@bues.ch>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	b43-dev <b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1452483457-568-1-git-send-email-baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11 January 2016 at 04:37, Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org> wrote:
> The memory allocated by kzalloc in b43_bus_dev_ssb_init is not freed.
> This patch fixes the bug by adding kfree in b43_ssb_remove.

Nice. If you want somethig more to scratch your head, see
"Missing b43 firmware handling"
http://lists.infradead.org/pipermail/b43-dev/2014-June/003467.html

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
