From: punit vara <punitvara@gmail.com>
Subject: Re: [PATCH v3 14/15] net: wireless: ath: Remove unneeded variable ret
 returning 0
Date: Fri, 23 Oct 2015 00:23:38 +0530
Message-ID: <CABXAfNJt4xOhyq1RkN7hNrajqaXLJmU42arydG8Z1KWVsPJ1uQ@mail.gmail.com>
References: <1445538363-2893-1-git-send-email-punitvara@gmail.com>
	<56292C55.4030706@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jirislaby@gmail.com, Nick Kossifidis <mickflemm@gmail.com>,
	mcgrof@do-not-panic.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56292C55.4030706@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 23, 2015 at 12:05 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 10/22/2015 09:26 PM, Punit Vara wrote:
>
>> This patch is to the ath5k/eeprom.c that fixes up warning caught by
>> coccicheck:
>>
>> -Unneeded variable: "ret". Return "0" on line 1733
>>
>> Remove unneccesary variable ret created to return zero.
>>
>> Also removed empty line suggested by Sergei
>>
>> Signed-off-by: Punit Vara <punitvara@gmail.com>
>> ---
>>   drivers/net/wireless/ath/ath5k/eeprom.c | 5 ++---
>>   1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/wireless/ath/ath5k/eeprom.c
>> b/drivers/net/wireless/ath/ath5k/eeprom.c
>> index 94d34ee..0c82ea5 100644
>> --- a/drivers/net/wireless/ath/ath5k/eeprom.c
>> +++ b/drivers/net/wireless/ath/ath5k/eeprom.c
>> @@ -1707,8 +1707,7 @@ ath5k_eeprom_read_spur_chans(struct ath5k_hw *ah)
>>         struct ath5k_eeprom_info *ee = &ah->ah_capabilities.cap_eeprom;
>>         u32 offset;
>>         u16 val;
>> -       int ret = 0, i;
>> -
>
>
>    No, this one shouldn't have been removed. There should an empty line
> between the declarations and the statements.
>
>> +       int i;
>>         offset = AR5K_EEPROM_CTL(ee->ee_version) +
>>                                 AR5K_EEPROM_N_CTLS(ee->ee_version);
>>
>
> MBR, Sergei
>

I have resent patch with update but I cant see it in my mailbox I dont
know Why.. Sorry if You are getting mail more time. I am sending final
version v5 as last.Please sorry for inconvenience
