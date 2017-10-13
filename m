From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] mwifiex: Use put_unaligned_le32
Date: Fri, 13 Oct 2017 09:42:43 +0000 (UTC)
Message-ID: <20171013094243.4C87C6070A@smtp.codeaurora.org>
References: <1507302279-3875-1-git-send-email-himanshujha199640@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: amitkarwar@gmail.com, nishants@marvell.com, gbhat@marvell.com,
        huxm@marvell.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Himanshu Jha <himanshujha199640@gmail.com>
To: Himanshu Jha <himanshujha199640@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507302279-3875-1-git-send-email-himanshujha199640@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Himanshu Jha <himanshujha199640@gmail.com> wrote:

> Use put_unaligned_le32 rather than using byte ordering function and
> memcpy which makes code clear.
> Also, add the header file where it is declared.
> 
> Done using Coccinelle and semantic patch used is :
> 
> @ rule1 @
> identifier tmp; expression ptr,x; type T;
> @@
> 
> - tmp = cpu_to_le32(x);
> 
>   <+... when != tmp
> - memcpy(ptr, (T)&tmp, ...);
> + put_unaligned_le32(x,ptr);
>   ...+>
> 
> @ depends on rule1 @
> type j; identifier tmp;
> @@
> 
> - j tmp;
>   ...when != tmp
> 
> Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>

Patch applied to wireless-drivers-next.git, thanks.

317049204cd3 mwifiex: Use put_unaligned_le32

-- 
https://patchwork.kernel.org/patch/9989655/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
