From: Shaun Crampton <Shaun.Crampton@metaswitch.com>
Subject: Re: ip_rcv_finish() NULL pointer and possibly related Oopses
Date: Fri, 4 Sep 2015 14:57:10 +0000
Message-ID: <D20F6FAC.43BD1%Shaun.Crampton@metaswitch.com>
References: <D2033B8F.4133C%Shaun.Crampton@metaswitch.com>
 <20150826074959.48aea34c@as>
 <CAGr1u3twv7KnXug3xZqL3X9NNpWBwGvw1RQpMHyqBmcC2ikamw@mail.gmail.com>
 <1440680401.8932.39.camel@edumazet-glaptop2.roam.corp.google.com>
 <D20CE2AD.43744%Shaun.Crampton@metaswitch.com>
 <55E7907D.9000606@iogearbox.net>
 <D20DBEF2.437A0%Shaun.Crampton@metaswitch.com>
 <55E80CFA.7050408@iogearbox.net>
 <D20DDAB4.437AF%Shaun.Crampton@metaswitch.com>
 <1441282243.8932.219.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Michael Marineau <michael.marineau@coreos.com>,
	Chuck Ebbert <cebbert.lkml@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Peter White <Peter.White@metaswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from enficsets1.metaswitch.com ([192.91.191.38]:27103 "EHLO
	ENFICSETS1.metaswitch.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759416AbbIDO5N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 10:57:13 -0400
In-Reply-To: <1441282243.8932.219.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Content-ID: <5FF70E4E8987BD429F402706DB8B371A@metaswitch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/09/2015 13:10, "Eric Dumazet" <eric.dumazet@gmail.com> wrote:

>On Thu, 2015-09-03 at 10:09 +0000, Shaun Crampton wrote:
>> >...
>> >> Is there anything I can do on a running system to help figure this
>>out?
>> >> Some sort of kernel equivalent to pmap to find out what module or
>>device
>> >> owns that chunk of memory?
>> >
>> >Hmm, perhaps /proc/kallsyms could point to something.
>>0xffffffffa0087d81
>> >and 0xffffffffa008772b could be from the same module, if any.
>> 
>> Any good: https://transfer.sh/szGRE/kallsyms ?
>> 
>
>seems to be cryptd module.
>
>Have you tried to run an pristine upstream kernel ?

No, I haven't tried that; I'm not sure if it's feasible with CoreOS.
