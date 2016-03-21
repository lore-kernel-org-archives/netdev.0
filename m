From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] mwifiex: advertise low priority scan feature
Date: Mon, 21 Mar 2016 12:28:59 +0200
Message-ID: <87d1qogm50.fsf@kamboji.qca.qualcomm.com>
References: <1458547622-1632-1-git-send-email-wnhuang@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	djkurtz-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1458547622-1632-1-git-send-email-wnhuang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> (Wei-Ning
	Huang's message of "Mon, 21 Mar 2016 16:07:02 +0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> writes:

> From: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
>
> Low priority scan handling code which delays or aborts scan
> operation based on Tx traffic is removed recently. The reason
> is firmware already takes care of it in our new feature scan
> channel gap. Hence we should advertise low priority scan
> support to cfg80211.
>
> This patch fixes a problem in which OBSS scan request from
> wpa_supplicant was being rejected by cfg80211.
>
> Signed-off-by: Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

The From line states that this is written by Amitkumar but there's no
Signed-off-By line from him. I can't take this without that, please
resend.

(Wei-Ning's s-o-b line is correct, I just need also Amitkumar's line.)

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
