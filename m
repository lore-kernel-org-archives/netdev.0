From: Andrew <nitr0@seti.kr.ua>
Subject: Re: Kernel 4.1.12 crash
Date: Sun, 22 Nov 2015 12:45:14 +0200
Message-ID: <56519CBA.8010704@seti.kr.ua>
References: <564F26FF.3040605@seti.kr.ua> <564FA904.7020603@gmail.com>
 <5650287B.9070901@seti.kr.ua> <56514FF5.7060906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.seti.kr.ua ([91.202.132.4]:58829 "EHLO mail.seti.kr.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbbKVKpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Nov 2015 05:45:19 -0500
Received: from [91.202.135.100] (helo=[192.168.0.145])
	by mail.seti.kr.ua with esmtpa (Exim 4.68)
	(envelope-from <nitr0@seti.kr.ua>)
	id 1a0S8w-0001aT-6p
	for netdev@vger.kernel.org; Sun, 22 Nov 2015 12:45:16 +0200
In-Reply-To: <56514FF5.7060906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

22.11.2015 07:17, Alexander Duyck wrote:
> On 11/21/2015 12:16 AM, Andrew wrote:
>> Memory corruption, if happens, IMHO shouldn't be a hardware-related -
>> almost all of these boxes, except H61M-based box from 1st log, works
>> for a long time with uptime more than year; and only software was
>> changed on it; H61M-based box runs memtest86 for a tens of hours w/o
>> any error. If it was caused by hardware - they should crash even
>> earlier.
>
> I wasn't saying it was hardware related.  My thought is that it could
> be some sort of use after free or double free type issue. Basically
> what you end up with is the memory getting corrupted by software that
> is accessing regions it shouldn't be.
>
>> Rarely on different servers I saw 'zram decompression error' messages
>> (in this case I've got such message on H61M-based box).
>>
>> Also, other people that uses accel-ppp as BRAS software, have
>> different kernel panics/bugs/oopses on fresh kernels.
>>
>> I'll try to apply these patches, and I'll try to switch back to
>> kernels that were stable on some boxes.
>
> If you could bisect this it would be useful.  Basically we just need
> to determine where in the git history these issues started popping up
> so that we can then narrow down on the root cause.
>
> - Alex
IMHO bisecting will be too long, because these crashes aren't regular - 
once box may work for a month w/o troubles, and then - may crash twice 
per week with same load.

Maybe if I'll create 10-20k sessions in test environment, this will 
cause crash - but I'm not sure about this. I'll try to check this.
