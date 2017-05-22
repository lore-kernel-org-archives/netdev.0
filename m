From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: ray_cs: Avoid reading past end of buffer
Date: Mon, 22 May 2017 15:27:50 +0000 (UTC)
Message-ID: <20170522152750.1EC2A601D1@smtp.codeaurora.org>
References: <20170505223841.GA20367@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daniel Micay <danielmicay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170505223841.GA20367@beast>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
> Using memcpy() from a buffer that is shorter than the length copied means
> the destination buffer is being filled with arbitrary data from the kernel
> rodata segment. In this case, the source was made longer, since it did not
> match the destination structure size. Additionally removes a needless cast.
> 
> This was found with the future CONFIG_FORTIFY_SOURCE feature.
> 
> Cc: Daniel Micay <danielmicay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

e48d661eb13f ray_cs: Avoid reading past end of buffer

-- 
https://patchwork.kernel.org/patch/9714453/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
