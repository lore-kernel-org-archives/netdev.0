From: Adam Katz <adamkatz0@gmail.com>
Subject: Re: libpcap and tc filters
Date: Tue, 5 Jul 2011 23:07:43 +0300
Message-ID: <CAA0qwj5snv-Wz99Z7va19PZCyCew5SN48Et4c8Q1bJtGiJX_3g@mail.gmail.com>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
	<1309777908.26180.1.camel@mojatatu>
	<CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
	<CAA0qwj7cH8Ah69fBMkXpGkwG77TH_ZqMhKwj-Cc8Vc=F5c9SSw@mail.gmail.com>
	<1309784740.26180.21.camel@mojatatu>
	<CAA0qwj4=bOU3LDsRk591AtBWx2c_6uFwk0M4-AGrnxCPKjbbrw@mail.gmail.com>
	<1309788416.26180.63.camel@mojatatu>
	<CAA0qwj4FUpfdux73WCxFcjX0xp-zNtMwncRRmN7ea1Kr9FX3Kw@mail.gmail.com>
	<1309863403.1765.0.camel@mojatatu>
	<1309870021.1765.41.camel@mojatatu>
	<CAA0qwj5aBWrsqHGddW9FBV2srdGwVMzJKe84BTyRH0Dkr6KgVQ@mail.gmail.com>
	<1309874213.1765.45.camel@mojatatu>
	<CAA0qwj74cvZmkkmA8zBFuXeHdidMco2=de7Li9rDN5Wcp=-G7w@mail.gmail.com>
	<1309876868.1765.53.camel@mojatatu>
	<CAA0qwj49XzNa-nY82X3d_eZ95seS15qELbJDYCNfRkg03OJosQ@mail.gmail.com>
	<1309882485.2271.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA0qwj6Wanp45ntTm0FK+fM37b_N8+T72VJfr9Et8oVb9LqOrg@mail.gmail.com>
	<1309893553.1733.41.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52905 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930Ab1GEUHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 16:07:44 -0400
Received: by iwn6 with SMTP id 6so5495466iwn.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 13:07:43 -0700 (PDT)
In-Reply-To: <1309893553.1733.41.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't think so. I tried different versions of tcpreplay.

The solution didn't work on 3 different ubuntu 10.04 machines with
2.6.32-32 (actually one of them had 2.6.32-31) but it DID work on a
fedora core 15 virtual machine with a newer kernel as well as a second
virtual machine with on which I installed stock ubuntu 11.04 just for
this test. It has 2.6.38 i think. On the last three machines (the
third ubuntu 10.04 as well as fc15 and ubuntu 11.04 tcpreplay came
straight from the repository).

Just to make myself clear - earlier, I tried the solution on a 10.04
physical box with various versions of tcpreplay, libpcap, and
iproute2. nothing worked.


On Tue, Jul 5, 2011 at 10:19 PM, jamal <hadi@cyberus.ca> wrote:
> On Tue, 2011-07-05 at 19:54 +0300, Adam Katz wrote:
>
>>
>> unless someone suggests a better solution, it seems like i'll be
>> adhering to the first law of engineering - "if it works, don't fix it"
>> and simply replace install fedora core 15 instead of ubuntu.
>
> My feeling is it has nothing to do with distro. Probably
> your tcpreplay?
>
> I am running ubuntu 10.04, but own compiled kernel (3.0-rc4).
> tcpreplay is older than Eric's version:
> --
> tcpreplay version: 3.4.3 (build 2375)
> Copyright 2001-2009 by Aaron Turner <aturner at synfin dot net>
> Cache file supported: 04
> Not compiled with libdnet.
> Compiled against libpcap: 1.0.0
> 64 bit packet counters: enabled
> Verbose printing via tcpdump: enabled
> Packet editing: disabled
> Fragroute engine: disabled
> Injection method: PF_PACKET send()
> ---
>
> cheers,
> jamal
>
>
