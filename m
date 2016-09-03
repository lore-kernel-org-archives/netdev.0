From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: fix:rtl8xxxu_core: mark symbols static where possible
Date: Sat, 03 Sep 2016 08:31:56 -0400
Message-ID: <wrfjpool2mgz.fsf@redhat.com>
References: <20160903102822.84E496201B@smtp.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Baoyou Xie <baoyou.xie@linaro.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@linaro.org, xie.baoyou@zte.com.cn
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160903102822.84E496201B@smtp.codeaurora.org> (Kalle Valo's
        message of "Sat, 3 Sep 2016 10:28:22 +0000 (UTC)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kalle Valo <kvalo@codeaurora.org> writes:
> Baoyou Xie <baoyou.xie@linaro.org> wrote:
>> We get 1 warning about global functions without a declaration
>> in the rtl8xxxu rtl8xxxu_core.c when building with W=1:
>> drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c:898:1:
>> warning: no previous prototype for 'rtl8xxxu_gen1_h2c_cmd'
>> [-Wmissing-prototypes]
>> 
>> In fact, this function is only used in the file in which it is declared
>> and don't need a declaration, but can be made static.
>> so this patch marks it 'static'.
>> 
>> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
>
> The title should be "rtl8xxxu: ". See:
>
> https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches#subject_name
>
> Also I assume Jes will take this.

Yes to both accounts!

Thanks,
Jes
