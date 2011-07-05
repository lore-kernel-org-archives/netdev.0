From: Adam Katz <adamkatz0@gmail.com>
Subject: Re: libpcap and tc filters
Date: Tue, 5 Jul 2011 19:54:37 +0300
Message-ID: <CAA0qwj6Wanp45ntTm0FK+fM37b_N8+T72VJfr9Et8oVb9LqOrg@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:41910 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017Ab1GEQyi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:54:38 -0400
Received: by iwn6 with SMTP id 6so5355804iwn.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 09:54:37 -0700 (PDT)
In-Reply-To: <1309882485.2271.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bah
I tried many times on both my ubuntu 10.04 boxes (2.6.32-32-generic)
one 32 bit, the other 64 and in both cases it simply refused to work.
I tried it with several different versions of libpcap (just in case)
as well as two different versions of tcpreplay (3.4.4 and 3.4.3) and
iproute (ubuntu 10.04 default version and the latest 2.6.39). One of
the machines had several NICs from different manufacturers so I tried
it on both too - and nothing!

However, once I moved to a third machine which is a virtual box with
fedora core 15 (2.6.38.6-26) - it suddenly worked.
In all cases I used the same pcap file and configuration.

unless someone suggests a better solution, it seems like i'll be
adhering to the first law of engineering - "if it works, don't fix it"
and simply replace install fedora core 15 instead of ubuntu.

On Tue, Jul 5, 2011 at 7:14 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 05 juillet 2011 =E0 18:16 +0300, Adam Katz a =E9crit :
>> strange.
>> I've now tried the exact same configuration and it simply refuses to
>> work. Maybe your tcpreplay is configured differently...
>>
>> What distro are you using? What kernel? What version of libpcap?
>
> I did the same tests here and it works correctly for me.
>
> latest kernel 3.0-rc6
>
> # /usr/local/bin/tcpreplay -V
> tcpreplay version: 3.4.4 (build 2450)
> Copyright 2000-2010 by Aaron Turner <aturner at synfin dot net>
> Cache file supported: 04
> Not compiled with libdnet.
> Compiled against libpcap: 1.1.1
> 64 bit packet counters: enabled
> Verbose printing via tcpdump: enabled
> Packet editing: disabled
> Fragroute engine: disabled
> Injection method: PF_PACKET send()
>
>
>
