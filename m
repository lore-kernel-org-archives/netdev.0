From: Mark Seger <Mark.Seger@hp.com>
Subject: Re: occasionally corrupted network stats in /proc/net/dev
Date: Mon, 14 Jan 2008 15:05:21 -0500
Message-ID: <478BC081.70101@hp.com>
References: <478B99E6.2050800@hp.com> <478BA53B.9060504@candelatech.com> <478BA8D7.8050803@hp.com> <478BAF47.10607@hp.com> <478BB43B.8060905@cosmosbay.com> <1200343269.15122.23.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:48270 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507AbYANUGA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 15:06:00 -0500
In-Reply-To: <1200343269.15122.23.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

outstanding!  I'm just happy to hear it's not a bug in my monitoring=20
code...  8-)
-mark

Michael Chan wrote:
> On Mon, 2008-01-14 at 20:12 +0100, Eric Dumazet wrote:
>  =20
>> Mark Seger a =C3=A9crit :
>>    =20
>>> Ignore that last one as it was pointed out to me that we have both =
nic=20
>>> installed on many of our systems and ethtool told me the one=20
>>> associated with the nic is actually the broadcom one.
>>>
>>> version:        1.4.38 E1B1EC867DEEB8027B2DA0F
>>> license:        GPL
>>> description:    Broadcom NetXtreme II BCM5706/5708 Driver
>>>
>>>      =20
>> I remember some tg3 chips actually have bugs when reporting stats...=
=2E=20
>> once in a while
>>
>> CCed to Michael Chan to get some details.
>>    =20
>
> Yes, that's right.  Some BNX2 chips have this problem and we have a
> workaround:
>
> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcom=
mit;h=3D02537b0676930b1bd9aff2139e0e645c79986931
>
> The chip sometimes DMA wrong counter values if the chip is also
> internally gathering the counters at the time of the DMA.
>
> Driver 1.5.11 and later versions have this workaround.
>
>
>  =20

