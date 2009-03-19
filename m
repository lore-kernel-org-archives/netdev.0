From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: next-20090318: sunhme does not transmit packets
Date: Thu, 19 Mar 2009 11:16:20 +0300
Message-ID: <a4423d670903190116p157b2ebfl69d270e0576c6d9a@mail.gmail.com>
References: <a4423d670903180734w7270a4f3qa2af3981b969436c@mail.gmail.com>
	 <a4423d670903180958j4847717eh99a41534633dd314@mail.gmail.com>
	 <20090318.234451.38898787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090318.234451.38898787.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/3/19 David Miller <davem@davemloft.net>:
> From: Alexander Beregalov <a.beregalov@gmail.com>
> Date: Wed, 18 Mar 2009 19:58:40 +0300
>
>> 2009/3/18 Alexander Beregalov <a.beregalov@gmail.com>:
>> > Hi
>> >
>> > Ultra 10 can boot, it receives DHCP answer, ssh works, but few minutes
>> > after machine becomes unresponsible by net at all.
>> > It does not respond even on ARP requests.
>> >
>> > On Sparc host I see that `TX packets` does not grow, but RX grows.
>> > The state of the interface is
>> > UP BROADCAST RUNNING MULTICAST
>> >
>> > There is no relevant kernel messages in dmesg.
>> >
>> > next-20090317 worked fine.
>> >
>> >
>> > Let me know if I can help.
>> >
>>
>> I have reproduced it on next-20090318 for the second time, but still
>> do not know how.
>> next-20090317 might be affected.
>>
>> Now both packet counters grow, but tcpdump cannot capture any packet.
>
> Does the current vanilla kernel work fine?

Yes. The problem happens only with -next tree.
