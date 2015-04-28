From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] iwl4965: Enable checking of format strings
Date: Tue, 28 Apr 2015 19:19:02 +0300
Message-ID: <877fsw5iq1.fsf@kamboji.qca.qualcomm.com>
References: <1423695069-23436-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1423695069-23436-1-git-send-email-linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
	(Rasmus Villemoes's message of "Wed, 11 Feb 2015 23:51:08 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org> writes:

> Since these fmt_* variables are just const char*, and not const
> char[], gcc (and smatch) doesn't to type checking of the arguments to
> the printf functions. Since the linker knows perfectly well to merge
> identical string constants, there's no point in having three static
> pointers waste memory and give an extra level of indirection.
>
> This removes over 100 "non-constant format argument" warnings from
> smatch, accounting for about 20% of all such warnings in an
> allmodconfig.
>
> Signed-off-by: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>

So what's the conclusion, should I commit this patch or not?

Full discussion here:

https://patchwork.kernel.org/patch/5814811/

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
