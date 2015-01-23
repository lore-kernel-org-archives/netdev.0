From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 3/6] rtlwifi: btcoexist: Add routines for RTL8812AE with
 single antenna
Date: Fri, 23 Jan 2015 14:24:27 -0600
Message-ID: <54C2ADFB.2080806@lwfinger.net>
References: <1422033044-7461-1-git-send-email-Larry.Finger@lwfinger.net>	<1422033044-7461-4-git-send-email-Larry.Finger@lwfinger.net> <87r3uljm7o.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87r3uljm7o.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/23/2015 02:06 PM, Kalle Valo wrote:
> Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> writes:
>
>> From: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
>>
>> The RTL8812AE needs different BT coexistence routines than does the
>> RTL8821AE. This patch adds the necessary routines for devices with a
>> single antenna.
>>
>> Signed-off-by: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
>> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
>> ---
>>   .../wireless/rtlwifi/btcoexist/halbtc8812a1ant.c   | 2073 ++++++++++++++++++++
>>   .../wireless/rtlwifi/btcoexist/halbtc8812a1ant.h   |  152 ++
>>   2 files changed, 2225 insertions(+)
>>   create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a1ant.c
>>   create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a1ant.h
>>
>> diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a1ant.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a1ant.c
>> new file mode 100644
>> index 0000000..11ae66b
>> --- /dev/null
>> +++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a1ant.c
>> @@ -0,0 +1,2073 @@
>> +/*  */
>> +/*  Description: */
>> +/*  */
>> +/*  This file is for 8812a1ant Co-exist mechanism */
>> +/*  */
>> +/*  History */
>> +/*  2012/11/15 Cosa first check in. */
>> +/*  */
>> +/*  */
>> +
>> +/*  */
>> +/*  include files */
>> +/*  */
>
> One problem I see is that there's no license on either of the files. It
> would be much better if the files had that.

I will add that and send a V2 after I wait a while for any other comments.

Thanks,

Larry



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
