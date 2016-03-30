From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 06/16] wcn36xx: Fetch private sta data from sta entry instead of from vif
Date: Wed, 30 Mar 2016 08:18:45 +0300
Message-ID: <8760w4bl1m.fsf@kamboji.qca.qualcomm.com>
References: <1459231593-360-7-git-send-email-bjorn.andersson@linaro.org>
	<201603300022.MmhimaU1%fengguang.wu@intel.com>
	<20160329213721.GV8929@tuxbot>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild test robot <lkp@intel.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pontus Fuchs <pontus.fuchs@gmail.com>, kbuild-all@01.org,
	wcn36xx@lists.infradead.org,
	Eugene Krasnikov <k.eugene.e@gmail.com>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160329213721.GV8929@tuxbot> (Bjorn Andersson's message of
	"Tue, 29 Mar 2016 14:37:21 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> writes:

>> All error/warnings (new ones prefixed by >>):
>> 
>>    drivers/net/wireless/ath/wcn36xx/main.c: In function 'wcn36xx_set_key':
>> >> drivers/net/wireless/ath/wcn36xx/main.c:389:9: error: implicit declaration of function 'wcn36xx_sta_to_priv' [-Werror=implicit-function-declaration]
>>      struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
>>             ^
>> >> drivers/net/wireless/ath/wcn36xx/main.c:389:33: warning: initialization makes pointer from integer without a cast
>>      struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
>>                                     ^
>>    cc1: some warnings being treated as errors
>
> This should have been reordered with patch 7, that introduces this
> helper function. Do you want me to resend, or can you apply the patches
> out of order?

It's better that you resend the whole patchset as v2.

-- 
Kalle Valo
