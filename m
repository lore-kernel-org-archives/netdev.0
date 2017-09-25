From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: make const array tos_to_ac static,
 reduces object code size
Date: Mon, 25 Sep 2017 08:24:59 +0000 (UTC)
Message-ID: <20170925082459.B18ED60719@smtp.codeaurora.org>
References: <20170919210500.31330-1-colin.king@canonical.com>
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
In-Reply-To: <20170919210500.31330-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate the read-only const array tos_to_ac on the stack,
> instead make it static. Makes the object code smaller by 250 bytes:
> 
> Before:
>    text	   data	    bss	    dec	    hex	filename
>   26104	   2720	    128	  28952	   7118	wmm.o
> 
> After:
>    text	   data	    bss	    dec	    hex	filename
>   25758	   2816	    128	  28702	   701e	wmm.o
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Patch applied to wireless-drivers-next.git, thanks.

7dfb0ebd022b mwifiex: make const array tos_to_ac static, reduces object code size

-- 
https://patchwork.kernel.org/patch/9960331/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
