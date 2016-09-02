From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [v2] ath9k: mark ath_fill_led_pin() static
Date: Fri, 2 Sep 2016 18:09:12 +0200
Message-ID: <7db487f5a15c4563a92de6da26a633fd@euamsexm01a.eu.qualcomm.com>
References: <1472473273-2972-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <ath9k-devel@qca.qualcomm.com>, <kvalo@codeaurora.org>,
        <linux-wireless@vger.kernel.org>, <ath9k-devel@lists.ath9k.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <arnd@arndb.de>, <baoyou.xie@linaro.org>, <xie.baoyou@zte.com.cn>
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472473273-2972-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Baoyou Xie <baoyou.xie@linaro.org> wrote:
> We get 1 warning about global functions without a declaration
> in the ath9k gpio driver when building with W=1:
> drivers/net/wireless/ath/ath9k/gpio.c:25:6: warning: no previous prototype for 'ath_fill_led_pin' [-Wmissing-prototypes]
> 
> In fact, this function is only used in the file in which it is declared
> and don't need a declaration, but can be made static.
> so this patch marks it 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Thanks, 1 patch applied to ath-next branch of ath.git:

c39265f72ae6 ath9k: mark ath_fill_led_pin() static

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9303795/
