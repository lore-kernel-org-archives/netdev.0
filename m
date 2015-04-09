From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: [PATCH 4/4] netfilter: Fix format string of nfnetlink_queue proc
 file
Date: Thu, 09 Apr 2015 23:58:14 +0200
Message-ID: <5526F5F6.4010907@nod.at>
References: <1426246276-15839-1-git-send-email-richard@nod.at> <1426246276-15839-5-git-send-email-richard@nod.at> <20150313121539.GA14488@salvia> <5502E99A.2060901@nod.at> <20150313135329.GA6054@salvia> <5502F28F.9050601@nod.at> <20150316131113.GA5744@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org, lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150316131113.GA5744@salvia>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am 16.03.2015 um 14:11 schrieb Pablo Neira Ayuso:
> On Fri, Mar 13, 2015 at 03:22:07PM +0100, Richard Weinberger wrote:
>> Am 13.03.2015 um 14:53 schrieb Pablo Neira Ayuso:
>>>> You mean statistics via netlink attributes? I can add that!
>>>
>>> Add a new NFQNL_CFG_CMD_STATS command to request the statistics. If
>>> NLM_F_DUMP is set, then we'll basically provide the full list of
>>> instances. Otherwise, in case you want to retrieve stats for a
>>> specific netlink socket, you can use the netlink portID as index.
>>> And you'll have to add attributes for this new command, yes.
>>
>> This was my plan. Thanks for the pointer!
> 
> It would be great if you can contribute this new interface.

FYI, it is still on my TODO.
I fear I won't find the time to do a patch for the upcoming merge window
and it has to wait for v4.2.

>>>> But I think we should also fix the format string of the proc file
>>>> as the fix is easy and non-intrusive.
>>>
>>> Unfortunately we don't know how many people are relying on that
>>> output, I prefer to remain conservative and provide a proper netlink
>>> interface for this.
>>
>> I understand your concerns but an application which is able to parse positive
>> and negative numbers can also parse pure positives.
>> Just made a small test application, glibc's %d in sscanf() can also deal with UINT_MAX.
>> And I don't expect that applications to check whether the returned values from
>> /proc/net/netfilter/nfnetlink_queue are between INT_MIN and INT_MAX.
>>
>> That said, I'd have assumed that an user would report negative values as plain kernel bug.
> 
> Makes sense, please fix net/netfilter/nfnetlink_log.c too.

Patches sent! :)

Thanks,
//richard
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
