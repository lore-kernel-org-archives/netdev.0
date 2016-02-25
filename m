From: Kuba Kicinski <kubakici-5tc4TXWwyLM@public.gmane.org>
Subject: Re: [PATCH][V3] mt7601u: do not free dma_buf when ivp allocation fails
Date: Thu, 25 Feb 2016 18:36:31 -0500
Message-ID: <286FE43B-A725-4BE0-B490-E91A107F8D0B@wp.pl>
References: <1456442667-19751-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1456442667-19751-1-git-send-email-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 25 February 2016 18:24:27 GMT-05:00, Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
>From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>
>If the allocation of ivp fails the error handling attempts to
>free an uninitialized dma_buf; this data structure just contains
>garbage on the stack, so the freeing will cause issues when the
>urb, buf and dma fields are free'd. Fix this by not free'ing the
>dma_buf if the ivp allocation fails.
>
>Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

LGTM, thanks.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
