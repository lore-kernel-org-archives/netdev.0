From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [next] ar5523: use container_of
Date: Fri, 13 Mar 2015 14:07:49 +0000 (UTC)
Message-ID: <20150313140749.B266A1415F0@smtp.codeaurora.org>
References: <1425997539-25206-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
To: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425997539-25206-1-git-send-email-fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> If we want to shrink skb->cb then we'd have to see about
> reducing struct ieee80211_tx_info, which gets embedded inside
> skb->cb[].
> 
> It provides a scratch space to be used by wireless drivers.
> ar5523 uses the maximum space available today (40 bytes), but it seems
> we don't need this -- data->skb pointer seems to always point back to the
> skb whose cb buffer the data structure resides, iow, given a pointer to the
> embedded control buffer we can infer the skb address.
> 
> Tested-by: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
