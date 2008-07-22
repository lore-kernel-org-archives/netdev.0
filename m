From: Patrick McHardy <kaber@trash.net>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330 __netif_schedule+0x2c/0x98()
Date: Tue, 22 Jul 2008 20:44:06 +0200
Message-ID: <48862A76.8030307@trash.net>
References: <4885104A.2070201@lwfinger.net>	<20080721.161517.27161039.davem@davemloft.net>	<48857F74.2040406@lwfinger.net> <20080722.043220.247312412.davem@davemloft.net> <4885DA49.50703@lwfinger.net> <48860D4B.8070003@lwfinger.net> <488616C0.8070505@trash.net> <4886294C.4060905@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40099 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682AbYGVSoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 14:44:55 -0400
In-Reply-To: <4886294C.4060905@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger wrote:
> Patrick McHardy wrote:
>> Larry Finger wrote:
>>>
>>> =============================================
>>> [ INFO: possible recursive locking detected ]
>>> 2.6.26-Linus-git-05752-g93ded9b #49
>>
>>                    ^^^^^^^^^^^^^^ dirty?
>>
>> This kernel is not using the patches we sent.
>
> No, but they didn't make any difference. I tried with all 3 applied, 
> then backed them out one by one. That was the state when I posted before.

Well, this is a completely different warning.

>
> Here are the dumps with all 3 patches applied:
>
> =============================================
> [ INFO: possible recursive locking detected ]
> 2.6.26-Linus-05752-g93ded9b-dirty #53
> ---------------------------------------------
> b43/1997 is trying to acquire lock:
>  (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
> ieee80211_scan_completed+0x130/0x2e1 [mac80211]
>
> but task is already holding lock:
>  (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
> ieee80211_scan_completed+0x130/0x2e1 [mac80211] 

