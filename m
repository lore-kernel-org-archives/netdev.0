From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] net: wireless: rtlwifi: rtl8192de: phy.c: Cleaning up
 uninitialized variables
Date: Sun, 1 Jun 2014 18:44:15 +0200
Message-ID: <CAFo99gYJ_K9qEaHihtvaFT4Wv3ApUZMJmTK=nuqK+=sA2NaYsA@mail.gmail.com>
References: <1401626948-16183-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<538B5714.6060107@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <538B5714.6060107@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei!

Okay, sorry. But you agree with what it is doing in general then?

In this case, I am sending a new patch...

Best regards
Rickard Strandqvist


2014-06-01 18:38 GMT+02:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
>
> On 06/01/2014 04:49 PM, Rickard Strandqvist wrote:
>
>> There is a risk that the variable will be used without being initialized.
>
>
>> This was largely found by using a static code analysis program called
>> cppcheck.
>
>
>> Signed-off-by: Rickard Strandqvist
>> <rickard_strandqvist@spectrumdigital.se>
>> ---
>>   drivers/net/wireless/rtlwifi/rtl8192de/phy.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>
>
>> diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
>> b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
>> index 3d1f0dd..66abaf6 100644
>> --- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
>> +++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
>> @@ -203,11 +203,11 @@ u32 rtl92d_phy_query_bb_reg(struct ieee80211_hw *hw,
>> u32 regaddr, u32 bitmask)
>>         struct rtl_priv *rtlpriv = rtl_priv(hw);
>>         struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
>>         u32 returnvalue, originalvalue, bitshift;
>> -       u8 dbi_direct;
>>
>>         RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "regaddr(%#x),
>> bitmask(%#x)\n",
>>                  regaddr, bitmask);
>>         if (rtlhal->during_mac1init_radioa ||
>> rtlhal->during_mac0init_radiob) {
>> +               u8 dbi_direct = 0;
>
>
>    Empty line is needed here, after declarations, like above.
>
>
>>                 /* mac1 use phy0 read radio_b. */
>>                 /* mac0 use phy1 read radio_b. */
>>                 if (rtlhal->during_mac1init_radioa)
>
>
> WBR, Sergei
>
