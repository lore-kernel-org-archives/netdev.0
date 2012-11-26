From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH net-next] gro: Handle inline VLAN tags
Date: Mon, 26 Nov 2012 10:04:44 -0500
Message-ID: <50B3850C.4070902@myri.com>
References: <1353111414.10798.64.camel@edumazet-glaptop> <1353112324.2743.81.camel@bwh-desktop.uk.solarflarecom.com> <1353114559.10798.66.camel@edumazet-glaptop> <20121119.191002.1995098917961576324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:36613 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249Ab2KZPEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 10:04:47 -0500
Received: by mail-gg0-f174.google.com with SMTP id k2so1966122ggd.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 07:04:47 -0800 (PST)
In-Reply-To: <20121119.191002.1995098917961576324.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/12 19:10, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 16 Nov 2012 17:09:19 -0800
>
>> On Sat, 2012-11-17 at 00:32 +0000, Ben Hutchings wrote:
>>> On Fri, 2012-11-16 at 16:16 -0800, Eric Dumazet wrote:
>>>> On Sat, 2012-11-17 at 00:00 +0000, Ben Hutchings wrote:
>>>>
>>>>> I'm not sure what you mean by this.  Is your point that the
>>>>> copy-on-write is never needed?  It is still possible for pskb_may_pull()
>>>>> to fail.
>>>>>
>>>>
>>>> A packet sniffer should have a copy of bad frames, even if dropped later
>>>> in our stacks.
>>>>
>>>> GRO layer is not allowed to drop a frame, even if not 'correct'.
>>>
>>> What do you think the accelerated hardware does with frames that have a
>>> truncated VLAN tag?
>>
>> The hardware should send us the frame, exactly like when RX checksum is
>> wrong.
>
> I agree with Eric, and therefore will not apply this patch.
>

David,

How do you feel about the patchset I posted on 11/14/2012
([PATCH net-next 0/3] myri10ge: LRO to GRO conversion,
http://marc.info/?l=linux-netdev&m=135289838223920&w=2)
which moves myri10ge from LRO to GRO?

Specifically, if doing vlan decap in GRO is not OK, then how
about doing it in the driver?

BTW, if I have bungled something it the myri10ge patchset submission,
I do apologize. I don't frequently submit patches, and it is likely
I screwed up some convention..

Thanks,

Drew
