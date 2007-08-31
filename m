From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 16:14:25 +0400
Message-ID: <46D80621.7060504@bigtelecom.ru>
References: <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local> <46D7F273.5010401@bigtelecom.ru> <46D7F4AB.10009@bigtelecom.ru> <20070831112815.GB3108@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:37811 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964941AbXHaMO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 08:14:28 -0400
In-Reply-To: <20070831112815.GB3108@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Fri, Aug 31, 2007 at 02:59:55PM +0400, Badalian Vyacheslav wrote:
>  =20
>> May be this bug eq "[PATCH] [NET_SCHED] sch_prio.c: remove duplicate=
=20
>> call of tc_classify()"?
>>
>>    =20
>>> I get kernel panic on 2.6.23-rc4-git2
>>> This is netconsole log!
>>>      =20
>> ...
>>
>>    =20
>
> So, it looks like you have found a really new (unknown) HTB bug,
> congratulations! We've only to find where is it hidden now...
>
> I don't think tc_classify could do such a harm to HTB, and can't
> see similar double calling as in sch_prio.
>
> Jarek P.
>
>  =20

Great! +)
I ready for patching and testing anything patches to find and fix probl=
em =3D)
Also i remember that bug up only if i delete HTB class and mashine have=
=20
lot of traffic.
I get statistic for last panic:
Script try to delete 25278 classes, Creating 8360 classes. Adding 6732=20
filters
Panic after 27 restarts of script.

