From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 02/11] rtlwifi: rtl8723be: Improve modinfo output
Date: Tue, 06 Jan 2015 09:59:06 -0600
Message-ID: <54AC064A.6090505@lwfinger.net>
References: <1420217908-1382-1-git-send-email-Larry.Finger@lwfinger.net> <1420217908-1382-3-git-send-email-Larry.Finger@lwfinger.net> <54A6E50E.8070205@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54A6E50E.8070205-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/02/2015 12:35 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 1/2/2015 7:58 PM, Larry Finger wrote:
>
>> The description of the power-save variables for this driver is not as
>> clear as for the others. The wording is changed to match the others.
>
>> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
>> ---
>>   drivers/net/wireless/rtlwifi/rtl8723be/sw.c | 11 ++++++-----
>>   1 file changed, 6 insertions(+), 5 deletions(-)
>
>> diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
>> b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
>> index 223eb42..52a6d90 100644
>> --- a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
>> +++ b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
>> @@ -387,12 +387,13 @@ module_param_named(swlps,
>> rtl8723be_mod_params.swctrl_lps, bool, 0444);
>>   module_param_named(fwlps, rtl8723be_mod_params.fwctrl_lps, bool, 0444);
>>   module_param_named(disable_watchdog, rtl8723be_mod_params.disable_watchdog,
>>              bool, 0444);
>> -MODULE_PARM_DESC(swenc, "using hardware crypto (default 0 [hardware])\n");
>> -MODULE_PARM_DESC(ips, "using no link power save (default 1 is open)\n");
>> -MODULE_PARM_DESC(fwlps, "using linked fw control power save (default 1 is
>> open)\n");
>> -MODULE_PARM_DESC(msi, "Set to 1 to use MSI interrupts mode (default 0)\n");
>
>     You are completely removing this description. Is it intentional?
>
>> +MODULE_PARM_DESC(swenc, "Set to 1 for software crypto (default 0)\n");
>> +MODULE_PARM_DESC(ips, "Set to 0 to not use link power save (default 1)\n");
>> +MODULE_PARM_DESC(swlps, "Set to 1 to use SW control power save (default 0)\n");
>> +MODULE_PARM_DESC(fwlps, "Set to 1 to use FW control power save (default 1)\n");
>>   MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
>> -MODULE_PARM_DESC(disable_watchdog, "Set to 1 to disable the watchdog (default
>> 0)\n");
>> +MODULE_PARM_DESC(disable_watchdog,
>> +         "Set to 1 to disable the watchdog (default 0)\n");
>
> WBR, Sergei

Good catch. Fixed in V2.

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
