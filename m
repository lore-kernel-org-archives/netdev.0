From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: p54: memset(0) whole array
Date: Thu, 17 Nov 2016 06:45:55 +0000 (UTC)
Message-ID: <20161117064555.F21F6615DB@smtp.codeaurora.org>
References: <20161014092309.24113-1-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161014092309.24113-1-jslaby-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org> wrote:
> gcc 7 complains:
> drivers/net/wireless/intersil/p54/fwio.c: In function 'p54_scan':
> drivers/net/wireless/intersil/p54/fwio.c:491:4: warning: 'memset' used with length equal to number of elements without multiplication by element size [-Wmemset-elt-size]
> 
> Fix that by passing the correct size to memset.
> 
> Signed-off-by: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
> Cc: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
> Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Acked-by: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

6f1758178820 p54: memset(0) whole array

-- 
https://patchwork.kernel.org/patch/9376333/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
