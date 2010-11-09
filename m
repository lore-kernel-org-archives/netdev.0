From: Luke Hutchison <luke.hutch@gmail.com>
Subject: Re: Networking hangs when too many parallel requests are made at once
Date: Tue, 9 Nov 2010 15:27:24 -0500
Message-ID: <AANLkTinz6C4s3wX7t6CsE2bzZ2adCoi0RAcqvpEFE2GV@mail.gmail.com>
References: <AANLkTikuCj=saH34dyO6xnU-y8rWv63hJaqowZ0ACLzk@mail.gmail.com>
 <AANLkTinRo_ozWFCYYqanOh0YrTJ6+KadutG2j7T726dY@mail.gmail.com> <4CD99E20.4060307@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:44323 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134Ab0KIU2F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 15:28:05 -0500
Received: by yxt3 with SMTP id 3so259507yxt.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 12:28:04 -0800 (PST)
In-Reply-To: <4CD99E20.4060307@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 9, 2010 at 2:16 PM, Ben Greear <greearb@candelatech.com> wr=
ote:
> On 11/09/2010 11:04 AM, Luke Hutchison wrote:
>>
>> On Tue, Nov 9, 2010 at 1:30 PM, Luke Hutchison<luke.hutch@gmail.com>
>> =C2=A0wrote:
>>>
>>> Since around Linux kernel 2.6.33 or so (but maybe as early as
>>> 2.6.31, not sure exactly what version), when restoring a crashed or
>>> closed browser session of either Firefox or Chrome where lots of ta=
bs
>>> (say 10-40) open simultaneously, the networking stack is brought to
>>> its knees -- most or all the tabs eventually time out without data,=
 or
>>> a few tabs might get some data and then display a partial web page.
>
> Have you been able to reproduce this on any other machine? =C2=A0I su=
spect
> it might be an issue with your specific NIC or other hardware.
>
> At the least, it's not a general problem with opening lots
> of TCP connections, as we routinely test with thousands...
>
> Thanks,
> Ben

No, I haven't been able to reproduce on any other machine.  But it
happens on both my wifi NIC and my ethernet NIC in this machine.

Thanks,
Luke
