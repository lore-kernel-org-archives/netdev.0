From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: pull request: wireless-next-2.6 2011-04-25
Date: Mon, 25 Apr 2011 15:55:24 -0500
Message-ID: <4DB5DFBC.3070203@lwfinger.net>
References: <20110425193017.GC28814@tuxdriver.com>	<20110425.125835.189703400.davem@davemloft.net> <20110425.130435.112597353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:57492 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757038Ab1DYUzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 16:55:51 -0400
In-Reply-To: <20110425.130435.112597353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2011 03:04 PM, David Miller wrote:
> From: David Miller<davem@davemloft.net>
> Date: Mon, 25 Apr 2011 12:58:35 -0700 (PDT)
>
>> From: "John W. Linville"<linville@tuxdriver.com>
>> Date: Mon, 25 Apr 2011 15:30:17 -0400
>>
>>> Here is another big batch of updates intended for 2.6.40...
>>>
>>> There is the usual huge batch of changes for ath9k, and iwlagn, a bunch
>>> for ath9k_htc, rt2x00, and ath5k, a few more for mwifiex, and a handful
>>> of others.  Also included is a big batch of Bluetooth updates as well.
>>>
>>> Please let me know if there are problems!
>>
>> Pulled, thanks a lot John.
>
> I guess watching the build logs for new warnings is too old fashioned
> for people, and besides Dave will do it for everyone anyways right?
>
> And this one is a real bug too. :-/
>
> I'll push this out to net-next-2.6 on top of the wireless-next pull,
> but please be more mindful in the future.

Unfortunately, the 64-bit variant of gcc v4.5.1 will miss some of these. I find 
I need to compile code on a 32-bit system and using an older compiler to catch 
all. Perhaps that explains the error that crept through here.

Larry

