From: m0sia <m0sia@plotinka.ru>
Subject: Re: [Bugme-new] [Bug 11571] New: u32_classify Kernel Panic
Date: Thu, 18 Sep 2008 13:05:28 +0600
Message-ID: <48D1FDB8.4040805@plotinka.ru>
References: <20080917193832.GA2623@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spark.plotinka.ru ([217.119.81.85]:43592 "EHLO
	spark.plotinka.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbYIRHe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 03:34:27 -0400
In-Reply-To: <20080917193832.GA2623@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Andrew Morton wrote, On 09/16/2008 06:15 PM:
>
>  =20
>> (switched to email.  Please respond via emailed reply-to-all, not vi=
a the
>> bugzilla web interface).
>>
>> On Mon, 15 Sep 2008 03:35:16 -0700 (PDT) bugme-daemon@bugzilla.kerne=
l.org wrote:
>>
>>    =20
>>> http://bugzilla.kernel.org/show_bug.cgi?id=3D11571
>>>
>>>            Summary: u32_classify Kernel Panic
>>>      =20
> ...
>
> Could you add more details:
> - .config
> - gzipped cls_u32.o (compiled with CONFIG_DEBUG_INFO on)
> - the first part of OOPS if possible.
> - more exactly these tc commands from your script
>
> Does this happen while creating or deleting something and is this
> easy to reproduce?
>
> Thanks,
> Jarek P.
>  =20

It happens on a production server and i can't experiment with this bug.=
=20
Now i'm using MARK iptable target and fw mark filter, because of this=20
bug. I think it happens when deleting or adding filters(it occur=20
automatically by script, when adding new user or user change speed).=20
I'll try this patch on test server.
