From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: [PATCH 6/9] Bluetooth: Silence DEBUG_STRICT_USER_COPY_CHECKS=y
 warning
Date: Fri, 13 May 2011 18:06:20 -0300
Message-ID: <20110513210620.GB2187@joana>
References: <1305244212-19183-1-git-send-email-sboyd@codeaurora.org>
 <1305244212-19183-7-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
To: Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1305244212-19183-7-git-send-email-sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

* Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> [2011-05-12 16:50:09 -0700]:

> Enabling DEBUG_STRICT_USER_COPY_CHECKS causes the following
> warning:
> 
> In function 'copy_from_user',
>     inlined from 'rfcomm_sock_setsockopt' at
>     net/bluetooth/rfcomm/sock.c:705:
> arch/x86/include/asm/uaccess_64.h:65:
> warning: call to 'copy_from_user_overflow' declared with
> attribute warning: copy_from_user() buffer size is not provably
> correct
> 
> presumably due to buf_size being signed causing GCC to fail to
> see that buf_size can't become negative.
> 
> Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
> Cc: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> Signed-off-by: Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> ---
>  net/bluetooth/rfcomm/sock.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)

Applied, thanks.

-- 
Gustavo F. Padovan
http://profusion.mobi
