From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: fix:rtl8xxxu_core: mark symbols static where possible
Date: Sat,  3 Sep 2016 10:28:21 +0000 (UTC)
Message-ID: <20160903102821.BFC0F62017@smtp.codeaurora.org>
References: <1472314476-23351-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jes.Sorensen@redhat.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@linaro.org, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472314476-23351-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Baoyou Xie <baoyou.xie@linaro.org> wrote:
> We get 1 warning about global functions without a declaration
> in the rtl8xxxu rtl8xxxu_core.c when building with W=1:
> drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c:898:1: warning: no previous prototype for 'rtl8xxxu_gen1_h2c_cmd' [-Wmissing-prototypes]
> 
> In fact, this function is only used in the file in which it is declared
> and don't need a declaration, but can be made static.
> so this patch marks it 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

The title should be "rtl8xxxu: ". See:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches#subject_name

Also I assume Jes will take this.

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9302457/
