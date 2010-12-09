From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: [Bugme-new] [Bug 24472] New: Kernel panic - not syncing: Fatal
 Exception
Date: Thu, 09 Dec 2010 20:59:11 +0100
Message-ID: <4D01350F.7060402@itcare.pl>
References: <bug-24472-10286@https.bugzilla.kernel.org/> <20101208122233.835a4997.akpm@linux-foundation.org> <4CFFEB01.7040700@itcare.pl> <4D000045.3040102@gmail.com> <4D00CE33.8040006@itcare.pl> <4D011813.1090200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl,
	Andrej Ota <andrej@ota.si>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:51182 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756636Ab0LIT7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 14:59:00 -0500
In-Reply-To: <4D011813.1090200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-12-09 18:55, Jarek Poplawski pisze:
> Pawe=C5=82 Staszewski wrote:
>> W dniu 2010-12-08 23:01, Jarek Poplawski pisze:
>>> Pawe=C5=82 Staszewski wrote:
>>>> W dniu 2010-12-08 21:22, Andrew Morton pisze:
>>>>> (switched to email.  Please respond via emailed reply-to-all, not
>>>>> via the
>>>>> bugzilla web interface).
>>>>>
>>>>> On Wed, 8 Dec 2010 20:14:45 GMT
>>>>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>>>>
>>>>>> https://bugzilla.kernel.org/show_bug.cgi?id=3D24472
>>>>>>
>>>>>>               Summary: Kernel panic - not syncing: Fatal Excepti=
on
>>>>>>               Product: Drivers
>>>>>>               Version: 2.5
>>>>>>        Kernel Version: 2.6.36.1
>>> Hi,
>>> Could you try to revert this patch?:
>>> http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.36.y.g=
it;a=3Dcommitdiff;h=3D55c95e738da85373965cb03b4f975d0fd559865b
>>>
>>>
>> After reverting this patch all is working
>> 200 connects-disconnects and no kernel panic
>>
>> I will make more session and test more.
> OK. I CC Andrej and Eric, who diagnosed it in this thread:
> http://lkml.org/lkml/2010/12/3/116
> [unable to handle kernel NULL pointer dereference in skb_dequeue]
>
> This should be also interesting:
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3Ddb7bf6d97c6956b7eb0f22131cb5c37bd41f33c0
>
> Thanks for testing,
> Jarek P.
>
>
After 10 hours of testing all is working.

I can't reproduce kernel panic now with houndreds of pppoe sessions tha=
t=20
connects-disconnects.


Thanks
Pawe=C5=82
