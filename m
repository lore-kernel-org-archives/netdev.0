From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: reproducable panic eviction work queue
Date: Sat, 18 Jul 2015 17:32:13 +0200
Message-ID: <55AA717D.8080800@cumulusnetworks.com>
References: <F8D94413-90A2-4F80-AAA2-7A6AB57DF314@transip.nl> <1437209795.1026.31.camel@edumazet-glaptop2.roam.corp.google.com> <5FD5C17E-B321-404E-80A2-EE46BB8AA746@transip.nl> <55AA243D.5020306@cumulusnetworks.com> <22C5EB62-8974-432D-9C3B-45F4E4067A45@transip.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"nikolay@redhat.com" <nikolay@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"chutzpah@gentoo.org" <chutzpah@gentoo.org>,
	Robin Geuze <robing@transip.nl>,
	Frank Schreuder <fschreuder@transip.nl>,
	netdev <netdev@vger.kernel.org>
To: Johan Schuijt <johan@transip.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:36630 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbbGRPcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 11:32:16 -0400
Received: by wgbcc4 with SMTP id cc4so8368481wgb.3
        for <netdev@vger.kernel.org>; Sat, 18 Jul 2015 08:32:15 -0700 (PDT)
In-Reply-To: <22C5EB62-8974-432D-9C3B-45F4E4067A45@transip.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2015 05:28 PM, Johan Schuijt wrote:
> Thx for your looking into this!
>=20
>>
>> Thank you for the report, I will try to reproduce this locally
>> Could you please post the full crash log ?
>=20
> Of course, please see attached file.
>=20
>> Also could you test
>> with a clean current kernel from Linus' tree or Dave's -net ?
>=20
> Will do.
>=20
>> These are available at:
>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
>> respectively.
>>
>> One last question how many IRQs do you pin i.e. how many cores
>> do you actively use for receive ?
>=20
> This varies a bit across our systems, but we=E2=80=99ve managed to re=
produce this with IRQs pinned on as many as 2,4,8 or 20 cores.
>=20
> I won=E2=80=99t have access to our test-setup till Monday again, so I=
=E2=80=99ll be testing 3 scenario=E2=80=99s then:
> - Your patch
-----
> - Linux tree
> - Dave=E2=80=99s -net tree
Just one of these two would be enough. I couldn't reproduce it here but
I don't have as many machines to test right now and had to improvise wi=
th VMs. :-)

>=20
> I=E2=80=99ll make sure to keep you posted on all the results then. We=
 have a kernel dump of the panic, so if you need me to extract any data=
 from there just let me know! (Some instructions might be needed)
>=20
> - Johan
>=20
Great, thank you!
