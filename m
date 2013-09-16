From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/8 V2] rtlwifi: rtl8192_common: Fix smatch errors and
 warnings in rtl8192c/dm_common.c
Date: Mon, 16 Sep 2013 23:10:23 +0400
Message-ID: <5237579F.3050104@cogentembedded.com>
References: <1379357722-17687-1-git-send-email-Larry.Finger@lwfinger.net> <1379357722-17687-5-git-send-email-Larry.Finger@lwfinger.net> <523755D1.2010003@cogentembedded.com> <523756DB.90507@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:54638 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880Ab3IPTK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 15:10:26 -0400
Received: by mail-la0-f44.google.com with SMTP id eo20so3537870lab.31
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 12:10:24 -0700 (PDT)
In-Reply-To: <523756DB.90507@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/16/2013 11:07 PM, Larry Finger wrote:

>>> Smatch lists the following:
>>>    CHECK   drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
>>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:551 rtl92c_dm_pwdb_monitor()
>>> info: ignoring unreachable code.
>>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:551 rtl92c_dm_pwdb_monitor()
>>> info: ignoring unreachable code.
>>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:870
>>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>>> 'txpwr_level' 2 <= 2
>>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:870
>>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>>> 'txpwr_level' 2 <= 2
>>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:882
>>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>>> 'txpwr_level' 2 <= 2
>>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:883
>>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>>> 'txpwr_level' 2 <= 2
>>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:891
>>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>>> 'txpwr_level' 2 <= 2
>>> drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c:892
>>> rtl92c_dm_txpower_tracking_callback_thermalmeter() error: buffer overflow
>>> 'txpwr_level' 2 <= 2

>>> The unreachable code message is fixed by commenting out the code that follows
>>> a return.

>>     You've commented out the whole function body, where is the *return* you're
>> talking about?

> The return is in the middle of the function body just after the variable
> declarations. It does not show in the diff listing, but it is there. What
> should I do?

    Just describe what you really did, I guess.

> Larry

WBR, Sergei
