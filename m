From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [v2] cw1200: Don't leak memory if krealloc failes
Date: Wed,  9 Nov 2016 01:37:00 +0000 (UTC)
Message-ID: <20161109013700.B3FEE61258@smtp.codeaurora.org>
References: <1475239157-16448-1-git-send-email-jthumshirn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Solomon Peachy <pizza-pCgMCH4qpMRg9hUCZPvPmw@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org>,
        Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475239157-16448-1-git-send-email-jthumshirn-l3A5Bk7waGM@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org> wrote:
> The call to krealloc() in wsm_buf_reserve() directly assigns the newly
> returned memory to buf->begin. This is all fine except when krealloc()
> failes we loose the ability to free the old memory pointed to by
> buf->begin. If we just create a temporary variable to assign memory to
> and assign the memory to it we can mitigate the memory leak.
> 
> Signed-off-by: Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org>
> Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

9afdd6128c39 cw1200: Don't leak memory if krealloc failes

-- 
https://patchwork.kernel.org/patch/9358185/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
