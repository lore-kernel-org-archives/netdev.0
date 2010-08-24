From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Tue, 24 Aug 2010 07:51:01 +0300
Message-ID: <4C734FB5.1090702@fs.uni-ruse.bg>
References: <20100820193835.GA6025@del.dom.local> <20100821074742.GA2367@del.dom.local> <1282377058.2636.12.camel@edumazet-laptop> <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg> <20100823124736.GA16966@ff.dom.local> <1282568443.2486.34.camel@edumazet-laptop> <20100823131056.GA19160@ff.dom.local> <4C727B06.2060002@fs.uni-ruse.bg> <4C72802D.8090405@fs.uni-ruse.bg> <20100823141437.GA2282@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:39245 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750851Ab0HXEvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 00:51:05 -0400
In-Reply-To: <20100823141437.GA2282@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 23.8.2010 =D0=B3. 17:14, Jarek Poplawski =D0=BD=D0=B0=D0=BF=
=D0=B8=D1=81=D0=B0:
> On Mon, Aug 23, 2010 at 05:05:33PM +0300, Plamen Petrov wrote:
>> Well, so far - so good. No oopses.
>>
>> I think I'm hitting some compiler related issue here...
>>
>> The kernel with the patch I sent applied is working pretty fine
>> even with "generic-receive-offload" ON for my tg3 nic...
>>
>> What is the big difference there?
>
> Oopses should be replaced with warnings, so please check the
> syslog etc from time to time.
>
> Jarek P.

So far - not so good. :(

After I left the machine, i rebooted once. Then I logged in
via ssh, and turned gro back ON for the tg3 nic - and in the
next 30 minutes - another reboot.

Today I will try to capture a picture of the oops/warning
with my phone camera, because contrary to what you suggest,
Jarek, there are no messages in the system logs.

Plamen
