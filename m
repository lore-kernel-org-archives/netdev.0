From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 4/8 V2] rtlwifi: rtl8192_common: Fix smatch errors and
 warnings in rtl8192c/dm_common.c
Date: Mon, 16 Sep 2013 14:07:07 -0500
Message-ID: <523756DB.90507@lwfinger.net>
References: <1379357722-17687-1-git-send-email-Larry.Finger@lwfinger.net> <1379357722-17687-5-git-send-email-Larry.Finger@lwfinger.net> <523755D1.2010003@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:37113 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab3IPTHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 15:07:13 -0400
In-Reply-To: <523755D1.2010003@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2013 02:02 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 09/16/2013 10:55 PM, Larry Finger wrote:
>
>> Smatch lists the following:
>>    CHECK   drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:551 rtl92c_dm_pwdb_monitor()
>> info: ignoring unreachable code.
>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:551 rtl92c_dm_pwdb_monitor()
>> info: ignoring unreachable code.
>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:870
>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>> 'txpwr_level' 2 <= 2
>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:870
>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>> 'txpwr_level' 2 <= 2
>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:882
>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>> 'txpwr_level' 2 <= 2
>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:883
>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>> 'txpwr_level' 2 <= 2
>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:891
>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>> 'txpwr_level' 2 <= 2
>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:892
>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>> 'txpwr_level' 2 <= 2
>
>> The unreachable code message is fixed by commenting out the code that follows
>> a return.
>
>     You've commented out the whole function body, where is the *return* you're
> talking about?

The return is in the middle of the function body just after the variable 
declarations. It does not show in the diff listing, but it is there. What should 
I do?

Larry
