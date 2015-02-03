From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH V2 1/6] rtlwifi: Change logging level for key change
Date: Tue, 03 Feb 2015 15:01:53 +0200
Message-ID: <87zj8vw3lq.fsf@kamboji.qca.qualcomm.com>
References: <1422304934-9239-1-git-send-email-Larry.Finger@lwfinger.net>
	<1422304934-9239-2-git-send-email-Larry.Finger@lwfinger.net>
	<54CBA794.90508@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:33120 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965603AbbBCNCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 08:02:00 -0500
In-Reply-To: <54CBA794.90508@lwfinger.net> (Larry Finger's message of "Fri, 30
	Jan 2015 09:47:32 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger <Larry.Finger@lwfinger.net> writes:

> On 01/26/2015 02:42 PM, Larry Finger wrote:
>> A recent change in key handling included logging of these changes for
>> all debug levels. Such key changes should only be logged when a high
>> level of debugging is enabled.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---
>>   drivers/net/wireless/rtlwifi/cam.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
>> index 3ef870d..6e64792 100644
>> --- a/drivers/net/wireless/rtlwifi/cam.c
>> +++ b/drivers/net/wireless/rtlwifi/cam.c
>> @@ -406,7 +406,7 @@ u8 rtl_cam_get_free_entry(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
>>   		}
>>   	}
>>   	if (found) {
>> -		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
>> +		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
>>   			 "key_index=%d,cam_bitmap: 0x%x entry_idx=%d\n",
>>   			  key_index, rtlpriv->sec.cam_bitmap, entry_idx);
>>   		return entry_idx;
>>
>
> Kalle,
>
> Please include this patch even though the rest of this set should be
> dropped.

I tried to do that but it failed:

Applying: rtlwifi: Change logging level for key change
fatal: sha1 information is lacking or useless (drivers/net/wireless/rtlwifi/cam.c).
Repository lacks necessary blobs to fall back on 3-way merge.
Cannot fall back to three-way merge.
Patch failed at 0001 rtlwifi: Change logging level for key change

I was not even able to find that code from cam.c. Have I missed a patch?

> Once the wifi-BT communications problem is resolved, new versions of
> those will be presented.

Sounds good.

> I'm sorry that my commit message was not as informative as it could
> have been. I was presented with this material that I did not
> understand. One saving grace is that the RTL8812AE hardware is
> apparently rare - I certainly do not have any samples. I'm not sure of
> the value of a 1x1 implementation of 802.11ac, but that may be another
> example of my ignorance.

No worries. But stuff like this is usually best to send as RFC first and
ask people to analyse it before sending it officially.

-- 
Kalle Valo
