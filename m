From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 2/7] rtlwifi: rtl8192de: Fix smatch warnings in rtl8192de/hw.c
Date: Sat, 14 Sep 2013 15:30:13 -0500
Message-ID: <5234C755.80709@lwfinger.net>
References: <1379094304-22041-1-git-send-email-Larry.Finger@lwfinger.net> <1379094304-22041-3-git-send-email-Larry.Finger@lwfinger.net> <5234C03A.2070701@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:52839 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932353Ab3INUaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Sep 2013 16:30:16 -0400
In-Reply-To: <5234C03A.2070701@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2013 02:59 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 09/13/2013 09:44 PM, Larry Finger wrote:
>
>> Smatch lists the following:
>>    CHECK   drivers/net/wireless/rtlwifi/rtl8192de/hw.c
>> drivers/net/wireless/rtlwifi/rtl8192de/hw.c:1200 rtl92de_set_qos() info:
>> ignoring unreachable code.
>> drivers/net/wireless/rtlwifi/rtl8192de/hw.c:1200 rtl92de_set_qos() info:
>> ignoring unreachable code.
>
>> Dead code is removed.
>
>     It is instead commented out, including non-dead code it seems...
>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---
>>   drivers/net/wireless/rtlwifi/rtl8192de/hw.c | 2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
>> b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
>> index 7dd8f6d..c9b0894 100644
>> --- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
>> +++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
>> @@ -1194,6 +1194,7 @@ void rtl92d_linked_set_reg(struct ieee80211_hw *hw)
>>    * mac80211 will send pkt when scan */
>>   void rtl92de_set_qos(struct ieee80211_hw *hw, int aci)
>>   {
>> +/*
>>       struct rtl_priv *rtlpriv = rtl_priv(hw);
>>       rtl92d_dm_init_edca_turbo(hw);
>>       return;
>
>     Shouldn't the comment start here (and *return* removed)? It's also
> better to remove the dead code than just to comment it out.

That would leave some unused variables.

>> @@ -1213,6 +1214,7 @@ void rtl92de_set_qos(struct ieee80211_hw *hw, int aci)
>>           RT_ASSERT(false, "invalid aci: %d !\n", aci);
>>           break;
>>       }
>> + */
>>   }

I'm not sure what that unreachable code might do, thus I saved it as a comment 
for possible future use. I need to do further evaluation on this fragment, and 
probably consult with the Realtek engineers.

Larry
