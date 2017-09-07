From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: Re: [PATCH] rtlwifi: btcoex: 23b 1ant: fix duplicated code for
 different branches
Date: Thu, 7 Sep 2017 09:35:49 -0500
Message-ID: <02176aa2-9af5-c933-74e1-b2333c07c36b@embeddedor.com>
References: <20170830134223.GA13596@embeddedgus>
 <ae09e952-112e-9616-735a-b86ba01ad398@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ae09e952-112e-9616-735a-b86ba01ad398@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Larry,

On 08/30/2017 11:48 PM, Larry Finger wrote:
> On 08/30/2017 08:42 AM, Gustavo A. R. Silva wrote:
>> Refactor code in order to avoid identical code for different branches.
>>
>> This issue was detected with the help of Coccinelle.
>>
>> Addresses-Coverity-ID: 1226788
>> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
>> ---
>> This issue was reported by Coverity and it was tested by compilation
>> only.
>> I'm suspicious this may be a copy/paste error. Please, verify.
>>
>>   .../net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c   | 10
>> ++--------
>>   1 file changed, 2 insertions(+), 8 deletions(-)
>
> This change is not correct. When bt_link_info->sco_exist is true, the
> call should be
>
>                 halbtc8723b1ant_limited_rx(btcoexist,
>                                NORMAL_EXEC, true,
>                                false, 0x5);
>
> NACK
>
> I will push the correct patch.
>

Great. Good to know.

Thanks
-- 
Gustavo A. R. Silva
