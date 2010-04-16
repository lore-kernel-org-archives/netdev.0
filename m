From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 14:02:29 +0800
Message-ID: <o2v412e6f7f1004152302j1aca5edam9d53d01781ddbe9d@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271268242.16881.1719.camel@edumazet-laptop> <1271271222.4567.51.camel@bigi>
	<20100415.014857.168270765.davem@davemloft.net> <1271332528.4567.150.camel@bigi>
	<4BC741AE.3000108@hp.com> <1271362581.23780.12.camel@bigi>
	<n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	<1271395106.16881.3645.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:58102 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455Ab0DPGCu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 02:02:50 -0400
Received: by gwaa18 with SMTP id a18so1185889gwa.19
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 23:02:49 -0700 (PDT)
In-Reply-To: <1271395106.16881.3645.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 1:18 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 16 avril 2010 =C3=A0 07:56 +0800, Changli Gao a =C3=A9cri=
t :
>> On Fri, Apr 16, 2010 at 4:16 AM, jamal <hadi@cyberus.ca> wrote:
>> >
>> > Sounds interesting.
>> > Wikipedia information overload. Any arch description of the HP9000=
?
>> > Did your scheme use IPIs to message the other CPUs?
>> >
>>
>> If you doubt the cost of smp_call_function_single(), how about havin=
g
>> a try with my another patch, which implements the similar of RPS, bu=
t
>> uses kernel threads instead, so no explicit IPI.
>>
>> http://patchwork.ozlabs.org/patch/38319/
>>
>>
>
> Come on Changli.
>
> How do you wake up a thread on a remote cpu ?
>

resched IPI, apparently. But it is async absolutely. and its IRQ
handler is lighter.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
