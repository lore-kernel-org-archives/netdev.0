From: Giedrius =?utf-8?Q?Statkevi=C4=8Dius?=
        <giedrius.statkevicius@gmail.com>
Subject: Re: [PATCH] ath9k: bring back direction setting in ath9k_{start_stop}
Date: Sat, 3 Sep 2016 19:08:51 +0300
Message-ID: <20160903160851.GA27396@tyrael>
References: <20160901174702.8645-1-giedrius.statkevicius@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: ath9k-devel@qca.qualcomm.com, linux-wireless@vger.kernel.org,
        ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Miaoqing Pan <miaoqing@codeaurora.org>,
        Kalle Valo <kvalo@qca.qualcomm.com>, stable@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160901174702.8645-1-giedrius.statkevicius@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some more users complaining about this:
https://bbs.archlinux.org/viewtopic.php?id=215978

On Thu, Sep 01, 2016 at 08:47:02PM +0300, Giedrius Statkevičius wrote:
> A regression was introduced in commit id 79d4db1214a ("ath9k: cleanup
> led_pin initial") that broken the WLAN status led on my laptop with
> AR9287 after suspending and resuming.
> 
> Steps to reproduce:
> * Suspend (laptop)
> * Resume (laptop)
> * Observe that the WLAN led no longer turns ON/OFF depending on the
>   status and is always red
> 
> Even though for my case it only needs to be set to OUT in ath9k_start
> but for consistency bring back the IN direction setting as well.
> 
> Cc: Miaoqing Pan <miaoqing@codeaurora.org>
> Cc: Kalle Valo <kvalo@qca.qualcomm.com>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Giedrius Statkevičius <giedrius.statkevicius@gmail.com>
> ---
[...]
