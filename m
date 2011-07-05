From: Adam Katz <adamkatz0@gmail.com>
Subject: Re: libpcap and tc filters
Date: Tue, 5 Jul 2011 17:21:21 +0300
Message-ID: <CAA0qwj74cvZmkkmA8zBFuXeHdidMco2=de7Li9rDN5Wcp=-G7w@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:40879 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095Ab1GEOVW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 10:21:22 -0400
Received: by iwn6 with SMTP id 6so5232530iwn.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 07:21:21 -0700 (PDT)
In-Reply-To: <1309874213.1765.45.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes. I understand the difference between ETH_P_ALL and ETH_P_IP...

Jamal, I've now tested both solutions - changing the rule to "protocol
all" and patching tcpreplay to use ETH_P_IP and both produced the
exact same problem as before...


On Tue, Jul 5, 2011 at 4:56 PM, jamal <hadi@cyberus.ca> wrote:
> On Tue, 2011-07-05 at 16:07 +0300, Adam Katz wrote:
>
>> second, I just took at the libpcap source code and it seems it's usi=
ng
>> the same ETH_P_ALL option when binding to an interface. So based on
>> what you're saying, the same solution of patching libpcap and
>> replacing ETH_P_ALL with =A0ETH_P_IP should also make these rules wo=
rk
>> with traffic sent using pure libpcap or any libpcap - based
>> application.
>
> ETH_P_ALL makes sense if you are unsure it is going to be IP. So i wo=
uld
> change/optimize apps only for IP if they are intended to deal with IP
> only (same for ARP etc).
> In your case, it seems it is tcp only - which runs on top of IP. So
> it makes sense to do it for that specific use case etc.
>
> cheers,
> jamal
>
>
>
