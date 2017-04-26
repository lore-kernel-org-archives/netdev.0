From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [1/1] mt7601u: check return value of alloc_skb
Date: Wed, 26 Apr 2017 09:03:05 +0000 (UTC)
Message-ID: <20170426090305.4C13361496@smtp.codeaurora.org>
References: <1492930823-17249-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <kubakici-5tc4TXWwyLM@public.gmane.org>,
        Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org>
To: Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1492930823-17249-1-git-send-email-bianpan2016-9Onoh4P/yGk@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org> wrote:
> Function alloc_skb() will return a NULL pointer if there is no enough
> memory. However, in function mt7601u_mcu_msg_alloc(), its return value
> is not validated before it is used. This patch fixes it.
> 
> Signed-off-by: Pan Bian <bianpan2016-9Onoh4P/yGk@public.gmane.org>
> Acked-by: Jakub Kicinski <kubakici-5tc4TXWwyLM@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

5fb01e91daf8 mt7601u: check return value of alloc_skb

-- 
https://patchwork.kernel.org/patch/9694549/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
