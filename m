From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Tue, 24 Aug 2010 16:27:59 +0300
Message-ID: <4C73C8DF.4060601@fs.uni-ruse.bg>
References: <20100820193835.GA6025@del.dom.local>	 <20100821074742.GA2367@del.dom.local>	 <1282377058.2636.12.camel@edumazet-laptop>	 <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg>	 <20100823124736.GA16966@ff.dom.local>	 <1282568443.2486.34.camel@edumazet-laptop>	 <20100823131056.GA19160@ff.dom.local> <4C727B06.2060002@fs.uni-ruse.bg>	 <4C72802D.8090405@fs.uni-ruse.bg> <20100823141437.GA2282@del.dom.local>	 <4C734FB5.1090702@fs.uni-ruse.bg> <1282626102.2378.1351.camel@edumazet-laptop> <4C738636.4000107@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:32918 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755073Ab0HXN2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:28:10 -0400
In-Reply-To: <4C738636.4000107@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 24.8.2010 =D0=B3. 11:43, Plamen Petrov =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0:
> =D0=9D=D0=B0 24.8.2010 =D0=B3. 08:01, Eric Dumazet =D0=BD=D0=B0=D0=BF=
=D0=B8=D1=81=D0=B0:
>> Le mardi 24 ao=C3=BBt 2010 =C3=A0 07:51 +0300, Plamen Petrov a =C3=A9=
crit :
>>> So far - not so good. :(
=2E..
>>
> Here is what I've got while running the kernel with the patch
> I attached earlier plus the above one, after turning GRO on for
> my tg3 nic:
>
> [picture 10]
> http://picpaste.com/37e37f9ff9504e3a003f49092f9b1be6.jpg
>
> [picture 11]
> http://picpaste.com/5663ca7c5041c0ed7a1f3e6a9aa17a9e.jpg
>
> [picture 12]
> http://picpaste.com/17f2ecaa409a1ebbf835a2e0519d3099.jpg
>
> Now moving on to the second proposed patch from Jarek.
>
> Thanks,
> Plamen

The current status: if I enable GRO on the tg3 - the kernel oopses.
It just takes a different amount of time to trigger: somewhere from
30 seconds to 30 minutes.

The oopses looks the same, and here are the latest:

[picture 13]
http://picpaste.com/c8dbda8f5c15d9ce3e050dd7f245f5d0.jpg

[picture 14]
http://picpaste.com/646cca586b704c5b72d3cf9fa54c7344.jpg

I was wondering which debug options could help us track this down?

Thanks,
Plamen
