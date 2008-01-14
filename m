From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: occasionally corrupted network stats in /proc/net/dev
Date: Mon, 14 Jan 2008 20:12:59 +0100
Message-ID: <478BB43B.8060905@cosmosbay.com>
References: <478B99E6.2050800@hp.com> <478BA53B.9060504@candelatech.com> <478BA8D7.8050803@hp.com> <478BAF47.10607@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	mchan@broadcom.com
To: Mark Seger <Mark.Seger@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.151]:2136 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908AbYANTNU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 14:13:20 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2f12.orange.fr (SMTP Server) with ESMTP id 9572970001A3
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 20:13:18 +0100 (CET)
In-Reply-To: <478BAF47.10607@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Seger a =E9crit :
> Ignore that last one as it was pointed out to me that we have both ni=
c=20
> installed on many of our systems and ethtool told me the one=20
> associated with the nic is actually the broadcom one.
>
> version:        1.4.38 E1B1EC867DEEB8027B2DA0F
> license:        GPL
> description:    Broadcom NetXtreme II BCM5706/5708 Driver
>

I remember some tg3 chips actually have bugs when reporting stats....=20
once in a while

CCed to Michael Chan to get some details.


> -mark
>
> Mark Seger wrote:
>> I'll try to get data on the other systems reporting it and as I said=
=20
>> it does not  happen all that often AND you have to be looking for=20
>> it.  The system I've personally seen it happen on several times is=20
>> running RHEL4/U4 which redhat numbers 2.6.9-42 and from modinfo I se=
e:
>> version:        7.0.33-k2-NAPI 51E97FEE51D0772AFC89130
>> description:    Intel(R) PRO/1000 Network Driver
>>
>> -mark
>>
>> Ben Greear wrote:
>>> Mark Seger wrote:
>>>> I had posted the following on linux-net and haven't see any=20
>>>> responses possibly because nobody had any or that list is=20
>>>> obsolete.  I have been told this is the current list for everythin=
g=20
>>>> networking on linux so I thought I'd try again...
>>> Do you see this with multiple network drivers, or just with one=20
>>> particular driver.  If so, which one?
>>>
>>> Thanks,
>>> Ben
>>>
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>




