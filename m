From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: ath9k: make const array reg_hole_list static,
 reduces object code size
Date: Wed, 4 Oct 2017 11:09:11 +0200
Message-ID: <0458c03b374e494892d03dd4b6a889c9@euamsexm01e.eu.qualcomm.com>
References: <20170919204019.30804-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919204019.30804-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:

> Don't populate the read-only array reg_hole_list on the stack, instead make
> it static.  Makes the object code smaller by over 200 bytes:
> 
> Before:
>    text	   data	    bss	    dec	    hex	filename
>   57518	  15248	      0	  72766	  11c3e	debug.o
> 
> After:
>    text	   data	    bss	    dec	    hex	filename
>   57218	  15344	      0	  72562	  11b72	debug.o
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>

Patch applied to ath-next branch of ath.git, thanks.

eba0f28473b2 ath9k: make const array reg_hole_list static, reduces object code size

-- 
https://patchwork.kernel.org/patch/9960183/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
