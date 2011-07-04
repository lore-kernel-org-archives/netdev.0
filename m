From: Adam Katz <adamkatz0@gmail.com>
Subject: Re: libpcap and tc filters
Date: Mon, 4 Jul 2011 17:16:19 +0300
Message-ID: <CAA0qwj4FUpfdux73WCxFcjX0xp-zNtMwncRRmN7ea1Kr9FX3Kw@mail.gmail.com>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
	<1309777908.26180.1.camel@mojatatu>
	<CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
	<CAA0qwj7cH8Ah69fBMkXpGkwG77TH_ZqMhKwj-Cc8Vc=F5c9SSw@mail.gmail.com>
	<1309784740.26180.21.camel@mojatatu>
	<CAA0qwj4=bOU3LDsRk591AtBWx2c_6uFwk0M4-AGrnxCPKjbbrw@mail.gmail.com>
	<1309788416.26180.63.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:41799 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753797Ab1GDOQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 10:16:20 -0400
Received: by iwn6 with SMTP id 6so4471086iwn.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 07:16:20 -0700 (PDT)
In-Reply-To: <1309788416.26180.63.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks a lot
I can tell you I'm not the first one to have this problem, but it
doesn't seem to be common... but that's probably because people
usually don't try to shape traffic sent using libpcap.

I found this post from 2003 on lartc with the exact same problem but
with no replies:
http://mailman.ds9a.nl/pipermail/lartc/2003q4/011004.html


On Mon, Jul 4, 2011 at 5:06 PM, jamal <hadi@cyberus.ca> wrote:
> On Mon, 2011-07-04 at 16:24 +0300, Adam Katz wrote:
>> ok, I checked now and the packets sent by tcpreplay are identical to
>> the ones captured originally by wireshark.
>
> Ok - thanks for removing that variable.
>
>> I'm using the stock ubuntu 10.04 kernel that wasn't compiled with
>> CONFIG_CLS_U32_PERF so sudo tc -s filter ls dev eth1 shows nothing
>> useful (and i'm not sure that recompiling the entire kernel is worth
>> it to tell me what I already know - that these packets missed the
>> filters... but i'm willing to do it if you think that'll help).
>
> Not necessary as long as you can tell where the packets end up.
>
>> Anyway, I suspect the problem to be something else - I suspect that
>> the packets sent using tcpreplay simply skip the filters in the kernel
>> and are being injected somewhere afterwards. But this theory is
>> problematic since I find it strange that the packets do end up in the
>> default queue after all - hence they ARE seen by tc and they don't
>> skip tc entirely.
>
> I am not sure off top of my head why that would happen. I will try later
> to install tcpreplay and reproduce your test.
>
> cheers,
> jamal
>
>
