From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Mon, 29 Dec 2014 10:33:26 +0100
Message-ID: <CAGm1_kudtF9O4QChrKX1q=c9KwHEFZet=z7j=-_iCRE914X83Q@mail.gmail.com>
References: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com>
 <20141204165609.GJ18045@saruman> <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com>
 <20141210171724.GI4602@saruman> <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com>
 <20141210210234.GN4602@saruman> <CAGm1_ktYg4iDgK7jyi5etSVup61LdookkV+SaQZOpLb6M=y7hA@mail.gmail.com>
 <CAGm1_kuaqXrU4zhNUZeY85+OeXHApSUDjJdsXcyBdvHTNhLCmQ@mail.gmail.com>
 <20141212173210.GI7549@saruman> <CAGm1_kuYrGsfjRO6TVr554yS8dcD4_Z9-j9KL0xpD=X+31OkXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34464 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaL2Jdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 04:33:47 -0500
In-Reply-To: <CAGm1_kuYrGsfjRO6TVr554yS8dcD4_Z9-j9KL0xpD=X+31OkXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 8:19 PM, Yegor Yefremov
<yegorslists@googlemail.com> wrote:
> On Fri, Dec 12, 2014 at 6:32 PM, Felipe Balbi <balbi@ti.com> wrote:
>> Hi,
>>
>> On Fri, Dec 12, 2014 at 01:00:51PM +0100, Yegor Yefremov wrote:
>>> U-Boot version: 2014.07
>>> Kernel config is omap2plus with enabled USB
>>>
>>> # cat /proc/version
>>> Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
>>> 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
>>> Mon Dec 8 22:47:43 CET 2014
>>
>> Wasn't GCC 4.8.x total crap for building ARM kernels ? IIRC it was even
>> blacklisted. Can you try with 4.9.x just to make sure ?
>
> Will do.

Adding linux-omap. Beginning of this discussion:
http://comments.gmane.org/gmane.linux.network/341427

Quick summary: starting with kernel 3.18 or commit
55601c9f24670ba926ebdd4d712ac3b177232330 am335x (at least BBB and some
custom boards) stalls at high network load. Reproducible via nuttcp
within some minutes

nuttcp -S (on BBB)
nuttcp -t -N 4 -T30m 192.168.1.235 (on host)

As Felipe Balbi suggested, I tried both 4.8.3 and 4.9.2 toolchains,
but both show the same behavior.

Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
Mon Dec 8 22:47:43 CET 2014
Linux version 3.18.1 (user@user-VirtualBox) (gcc version 4.9.2
(Buildroot 2015.02-git-00582-g10b9761) ) #1 SMP Mon Dec 29 09:22:29
CET 2014

Let me know, if you can reproduce this issue.

Thanks.

Yegor
