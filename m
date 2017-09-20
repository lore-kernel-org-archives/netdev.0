From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: mwifiex: remove unnecessary call to memset
Date: Wed, 20 Sep 2017 12:47:13 +0000 (UTC)
Message-ID: <20170920124713.5A68B60725@smtp.codeaurora.org>
References: <1505133964-376-1-git-send-email-himanshujha199640@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: amitkarwar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, gbhat-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
        huxm-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Himanshu Jha <himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Himanshu Jha <himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1505133964-376-1-git-send-email-himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Himanshu Jha <himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> call to memset to assign 0 value immediately after allocating
> memory with kzalloc is unnecesaary as kzalloc allocates the memory
> filled with 0 value.
> 
> Semantic patch used to resolve this issue:
> 
> @@
> expression e,e2; constant c;
> statement S;
> @@
> 
>   e = kzalloc(e2, c);
>   if(e == NULL) S
> - memset(e, 0, e2);
> 
> Signed-off-by: Himanshu Jha <himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

85dafc129196 mwifiex: remove unnecessary call to memset

-- 
https://patchwork.kernel.org/patch/9947331/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
