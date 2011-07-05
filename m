From: jamal <hadi@cyberus.ca>
Subject: Re: libpcap and tc filters
Date: Tue, 05 Jul 2011 09:56:53 -0400
Message-ID: <1309874213.1765.45.camel@mojatatu>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
	 <1309777908.26180.1.camel@mojatatu>
	 <CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
	 <CAA0qwj7cH8Ah69fBMkXpGkwG77TH_ZqMhKwj-Cc8Vc=F5c9SSw@mail.gmail.com>
	 <1309784740.26180.21.camel@mojatatu>
	 <CAA0qwj4=bOU3LDsRk591AtBWx2c_6uFwk0M4-AGrnxCPKjbbrw@mail.gmail.com>
	 <1309788416.26180.63.camel@mojatatu>
	 <CAA0qwj4FUpfdux73WCxFcjX0xp-zNtMwncRRmN7ea1Kr9FX3Kw@mail.gmail.com>
	 <1309863403.1765.0.camel@mojatatu> <1309870021.1765.41.camel@mojatatu>
	 <CAA0qwj5aBWrsqHGddW9FBV2srdGwVMzJKe84BTyRH0Dkr6KgVQ@mail.gmail.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Adam Katz <adamkatz0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:53141 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036Ab1GEN46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 09:56:58 -0400
Received: by qyk29 with SMTP id 29so1501186qyk.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 06:56:57 -0700 (PDT)
In-Reply-To: <CAA0qwj5aBWrsqHGddW9FBV2srdGwVMzJKe84BTyRH0Dkr6KgVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-05 at 16:07 +0300, Adam Katz wrote:

> second, I just took at the libpcap source code and it seems it's using
> the same ETH_P_ALL option when binding to an interface. So based on
> what you're saying, the same solution of patching libpcap and
> replacing ETH_P_ALL with  ETH_P_IP should also make these rules work
> with traffic sent using pure libpcap or any libpcap - based
> application.

ETH_P_ALL makes sense if you are unsure it is going to be IP. So i would
change/optimize apps only for IP if they are intended to deal with IP
only (same for ARP etc).
In your case, it seems it is tcp only - which runs on top of IP. So
it makes sense to do it for that specific use case etc.

cheers,
jamal


