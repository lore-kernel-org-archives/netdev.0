From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH 1/1] ath10k: fixing wrong initialization of struct channel
Date: Fri, 24 Jul 2015 10:48:14 +0300
Message-ID: <87mvymf135.fsf@kamboji.qca.qualcomm.com>
References: <1437018933-25832-1-git-send-email-maninder1.s@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<pankaj.m-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
To: Maninder Singh <maninder1.s-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1437018933-25832-1-git-send-email-maninder1.s-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
	(Maninder Singh's message of "Thu, 16 Jul 2015 09:25:33 +0530")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Maninder Singh <maninder1.s-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org> writes:

> chandef is initialized with NULL and on the very next line,
> we are using it to get channel, which is not correct.
>
> channel should be initialized after obtaining chandef.
>
> Signed-off-by: Maninder Singh <maninder1.s-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>

Thanks, applied.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
