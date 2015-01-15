From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH for 3.19 3/3] rtlwifi: rtl8192ee: Fix several bugs
Date: Thu, 15 Jan 2015 11:05:20 -0600
Message-ID: <54B7F350.4040203@lwfinger.net>
References: <1421257036-5382-1-git-send-email-Larry.Finger@lwfinger.net>	<1421257036-5382-4-git-send-email-Larry.Finger@lwfinger.net> <87bnm0xoar.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87bnm0xoar.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/15/2015 05:42 AM, Kalle Valo wrote:
> Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> writes:
>
>> From: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
>>
>> The following bugs are fixed in this driver:
>> 1. Problems parsing C2H CMD
>> 2. An ad-hoc connection can cause a TX freeze.
>> 3. There are additional conditions that cause a TX freeze.
>> 4. The previous code failed to handle situations where an RX
>>     descriptor was unavailable.
>>
>> Signed-off-by: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
>> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
>
> Is this really so important that it should go to 3.19? A patch titled
> "Fix several bugs" immediately makes me cautious and then I look at the
> patch itself I see rewriting functions instead of simple bug fixes. From
> a quick look this looks more -next material than 3.19.

It is not a simple rewrite of functions. Tho mishandling of the descriptor ring 
buffer locks up the device and requires a cold boot. These patches prevent that 
from happening.

Yes, the patches are rather larger than I would like at the -rc4 stage, and I 
defer to your judgement. At least we have an external source of corrected code 
for users of 3.18 and 3.19.

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
