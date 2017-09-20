From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: make const arrays static to shink object code size
Date: Wed, 20 Sep 2017 12:47:40 +0000 (UTC)
Message-ID: <20170920124740.CCDD160912@smtp.codeaurora.org>
References: <20170916153424.28285-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <amitkarwar@gmail.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170916153424.28285-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate const arrays on the stack, instead make them static
> Makes the object code smaller by nearly 300 bytes:
> 
> Before:
>    text	   data	    bss	    dec	    hex	filename
>   69260	  16149	    576	  85985	  14fe1	cfg80211.o
> 
> After:
>    text	   data	    bss	    dec	    hex	filename
>   68385	  16725	    576	  85686	  14eb6	cfg80211.o
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Patch applied to wireless-drivers-next.git, thanks.

d157bcfaf854 mwifiex: make const arrays static to shink object code size

-- 
https://patchwork.kernel.org/patch/9954375/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
