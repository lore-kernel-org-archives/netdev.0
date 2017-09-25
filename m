From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: b43: make const arrays static, reduces object code size
Date: Mon, 25 Sep 2017 08:30:44 +0000 (UTC)
Message-ID: <20170925083044.D348A6025D@smtp.codeaurora.org>
References: <20170922153902.15372-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922153902.15372-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate const arrays on the stack, instead make them static.
> Makes the object code smaller by over 60 bytes:
> 
> Before:
>    text	   data	    bss	    dec	    hex	filename
>   14816	   1296	      0	  16112	   3ef0	b43/phy_ht.o
> 
> After:
>    text	   data	    bss	    dec	    hex	filename
>   14551	   1496	      0	  16047	   3eaf	b43/phy_ht.o
> 
> (gcc 6.3.0, x86-64)
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Patch applied to wireless-drivers-next.git, thanks.

96cbe3d638e4 b43: make const arrays static, reduces object code size

-- 
https://patchwork.kernel.org/patch/9966415/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
