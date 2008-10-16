From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: deadlocks if use htb
Date: Thu, 16 Oct 2008 12:28:46 +0400
Message-ID: <48F6FB3E.7060903@bigtelecom.ru>
References: <20081010075640.GA5204@ff.dom.local> <48EF17EA.5020306@bigtelecom.ru> <20081010090426.GA6054@ff.dom.local> <20081010095129.GB6054@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:50970 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107AbYJPI2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 04:28:51 -0400
In-Reply-To: <20081010095129.GB6054@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Fri, Oct 10, 2008 at 09:04:26AM +0000, Jarek Poplawski wrote:
>  =20
>> On Fri, Oct 10, 2008 at 12:52:58PM +0400, Badalian Vyacheslav wrote:
>>    =20
>>> Oh... sorry. I Wrong you understand... i patch 2.6.27 with this pat=
ch
>>> and will test it...
>>>      =20
>> No, you understood it right. But it seems 2.6.27 fix doesn't work fo=
r
>> you. So, yes, try this patch with 2.6.26 or 2.6.27.
>>    =20
>
> There is also a parameter you could try (without this patch):
>
> modprobe sch_htb htb_hysteresis=3D1
>
> Jarek P.
>
>  =20
>>>>> Please look to if you have time:
>>>>> http://bugzilla.kernel.org/show_bug.cgi?id=3D11718
>>>>>
>>>>> We have deadlocks at few PC one times in week.
>>>>> I can test any patches to detect and fix problem.
>>>>> Now i test 2.6.27-rc kernel at one PC.
>>>>>    =20
>>>>>          =20
>>>> A similar bug was reported by Denys Fedoryshchenko but it wasn't f=
ully
>>>> diagnosed. Anyway it looks like hardware dependent. The patch belo=
w
>>>> can sometimes help. 2.6.27 may have this fixed too (some other way=
).
>>>>
>>>> Jarek P.
>>>>        =20
>
>  =20
Sorry for long answer.

We have troubles with power in our server place. Now its gone and i wil=
l
test again all this.

With patch +  htb_hysteresis=3D0 and htb_hysteresis=3D1 without patch a=
ll PC
work done 2 days and 18 hours. After this we have power crash.... =3D(

Thanks
