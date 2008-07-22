From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330 __netif_schedule+0x2c/0x98()
Date: Tue, 22 Jul 2008 14:30:33 -0500
Message-ID: <48863559.1090104@lwfinger.net>
References: <4885104A.2070201@lwfinger.net>	<20080721.161517.27161039.davem@davemloft.net>	<48857F74.2040406@lwfinger.net> <20080722.043220.247312412.davem@davemloft.net> <4885DA49.50703@lwfinger.net> <48860D4B.8070003@lwfinger.net> <488616C0.8070505@trash.net> <4886294C.4060905@lwfinger.net> <48862A76.8030307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48862A76.8030307-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Larry Finger wrote:
>> Patrick McHardy wrote:
>>> Larry Finger wrote:
>>>>
>>>> =============================================
>>>> [ INFO: possible recursive locking detected ]
>>>> 2.6.26-Linus-git-05752-g93ded9b #49
>>>
>>>                    ^^^^^^^^^^^^^^ dirty?
>>>
>>> This kernel is not using the patches we sent.
>>
>> No, but they didn't make any difference. I tried with all 3 applied, 
>> then backed them out one by one. That was the state when I posted before.
> 
> Well, this is a completely different warning.
> 
>>
>> Here are the dumps with all 3 patches applied:
>>
>> =============================================
>> [ INFO: possible recursive locking detected ]
>> 2.6.26-Linus-05752-g93ded9b-dirty #53
>> ---------------------------------------------
>> b43/1997 is trying to acquire lock:
>>  (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
>> ieee80211_scan_completed+0x130/0x2e1 [mac80211]
>>
>> but task is already holding lock:
>>  (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
>> ieee80211_scan_completed+0x130/0x2e1 [mac80211] 

Sorry. After all those kernel builds I got bleary-eyed and just looked for 
recursive locking without any regard for the details.

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
