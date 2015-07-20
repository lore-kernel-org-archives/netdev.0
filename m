From: Frank Schreuder <fschreuder@transip.nl>
Subject: Re: reproducable panic eviction work queue
Date: Mon, 20 Jul 2015 14:47:37 +0200
Message-ID: <55ACEDE9.3090205@transip.nl>
References: <F8D94413-90A2-4F80-AAA2-7A6AB57DF314@transip.nl>
 <1437209795.1026.31.camel@edumazet-glaptop2.roam.corp.google.com>
 <5FD5C17E-B321-404E-80A2-EE46BB8AA746@transip.nl>
 <55AA243D.5020306@cumulusnetworks.com>
 <22C5EB62-8974-432D-9C3B-45F4E4067A45@transip.nl>
 <55AA717D.8080800@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"nikolay@redhat.com" <nikolay@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"chutzpah@gentoo.org" <chutzpah@gentoo.org>,
	Robin Geuze <robing@transip.nl>,
	netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Johan Schuijt <johan@transip.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0116.outbound.protection.outlook.com ([157.56.112.116]:16304
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753249AbbGTNUK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 09:20:10 -0400
In-Reply-To: <55AA717D.8080800@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 7/18/2015  05:32 PM, Nikolay Aleksandrov wrote:
> On 07/18/2015 05:28 PM, Johan Schuijt wrote:
>> Thx for your looking into this!
>>
>>> Thank you for the report, I will try to reproduce this locally
>>> Could you please post the full crash log ?
>> Of course, please see attached file.
>>
>>> Also could you test
>>> with a clean current kernel from Linus' tree or Dave's -net ?
>> Will do.
>>
>>> These are available at:
>>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
>>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
>>> respectively.
>>>
>>> One last question how many IRQs do you pin i.e. how many cores
>>> do you actively use for receive ?
>> This varies a bit across our systems, but we=E2=80=99ve managed to r=
eproduce this with IRQs pinned on as many as 2,4,8 or 20 cores.
>>
>> I won=E2=80=99t have access to our test-setup till Monday again, so =
I=E2=80=99ll be testing 3 scenario=E2=80=99s then:
>> - Your patch
> -----
>> - Linux tree
>> - Dave=E2=80=99s -net tree
> Just one of these two would be enough. I couldn't reproduce it here b=
ut
> I don't have as many machines to test right now and had to improvise =
with VMs. :-)
>
>> I=E2=80=99ll make sure to keep you posted on all the results then. W=
e have a kernel dump of the panic, so if you need me to extract any dat=
a from there just let me know! (Some instructions might be needed)
>>
>> - Johan
>>
> Great, thank you!
>
I'm able to reproduce this panic on the following kernel builds:
- 3.18.7
- 3.18.18
- 3.18.18 + patch from Nikolay Aleksandrov
- 4.1.0

Would you happen to have any more suggestions we can try?

Thanks,
=46rank

--=20

TransIP BV

Schipholweg 11E
2316XB Leiden
E: fschreuder@transip.nl
I: https://www.transip.nl
