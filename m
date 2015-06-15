From: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] wireless: ipw2100: fix timeout bug - always evaluated to 0
Date: Mon, 15 Jun 2015 22:25:32 +0400
Message-ID: <CA++WF2Ppn66VP8fq5Q-MXY_=7M3TqPM_tbF5VzWtVb1osyAngA@mail.gmail.com>
References: <1434389075-4693-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434389075-4693-1-git-send-email-hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 15 June 2015 at 21:24, Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org> wrote:
> commit: commit 2c86c275015c ("Add ipw2100 wireless driver.") introduced
> HW_PHY_OFF_LOOP_DELAY (HZ / 5000) which always evaluated to 0. Clarified
> by Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> that it should be 50
> milliseconds thus fixed up to msecs_to_jiffies(50).
>
> Signed-off-by: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
> ---
>
> Patch was compile tested with x86_64_defconfig + CONFIG_IPW2100=m
> (with a few buildwarnings in ipw2100.c though not related to this patch)
>
> Patch is against 4.1-rc7 (localversion-next is -next-20150615)
>
>  drivers/net/wireless/ipw2x00/ipw2100.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>

Acked-by: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Stanislav.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
