From: Ethan Tuttle <ethan@ethantuttle.com>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Mon, 16 Sep 2013 10:24:05 -0700
Message-ID: <CACzLR4ssOPsmYaEh2ohe4HL5j+67keDYnmR4YezNB=aO7Pj5kA@mail.gmail.com>
References: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com>
	<20130915205701.5c61a444@skate>
	<20130916065047.GH27487@1wt.eu>
	<20130916175152.4e013457@skate>
	<CACzLR4twTNjzU8hK3L1cYUXnEH1ydwY6jnYoOG+9vLB3-4uQ4w@mail.gmail.com>
	<20130916163937.GC3188@1wt.eu>
	<20130916164412.GD3188@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	=?ISO-8859-1?Q?Gregory_Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:61827 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab3IPRYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 13:24:06 -0400
Received: by mail-we0-f182.google.com with SMTP id q59so4078794wes.27
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 10:24:05 -0700 (PDT)
In-Reply-To: <20130916164412.GD3188@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 9:44 AM, Willy Tarreau <w@1wt.eu> wrote:
> On Mon, Sep 16, 2013 at 06:39:37PM +0200, Willy Tarreau wrote:
>> On Mon, Sep 16, 2013 at 09:35:16AM -0700, Ethan Tuttle wrote:
>> > On Mon, Sep 16, 2013 at 8:51 AM, Thomas Petazzoni
>> > <thomas.petazzoni@free-electrons.com> wrote:
>> > > Willy, Ethan,
>> > >
>> > > On Mon, 16 Sep 2013 08:50:47 +0200, Willy Tarreau wrote:
>> > >
>> > >> I'm currently testing on 3.11.1 (which I had here) and am not getting
>> > >> any issue after 50M packets. My kernel is running in thumb mode and
>> > >> without SMP.
>> > >>
>> > >> Ethan, we'll need your config I guess.
>> > >
>> > > Can both of you also report the U-Boot version you're using, and the
>> > > SoC revision (it's visible in the U-Boot output).
>> >
>> > Mine says:
>> >
>> > U-Boot 2009.08 (Sep 16 2012 - 22:50:06)Marvell version: 1.1.2 NQ
>> > SoC:   MV6710 A1
>>
>> I just checked on my old captures and I have the same here, with more
>> details such as the CPU's revision (Rev 1) :
>>
>>    http://1wt.eu/articles/mirabox-vs-guruplug/
>
> BTW Ethan, I don't know if you have already opened your mirabox, but on the
> link above you'll find settings for trying other frequencies for the CPU. It
> could be nice to try 1 GHz with L2/DDR @500 instead of 1200/600 to see if the
> issue remains or not. If it disappears, there's also a working setting with
> CPU@1.2G, L2@800M and DDR@400M to help find if CPU, L2 or DDR is the culprit.
>
> Willy
>

I have not opened my mirabox - but sure, I'll open it up and try those
other settings when I get a chance.

Also, you mentioned that you have SMP disabled in your kernel.  It
looks like it's on in my .config.  Should I run a test with SMP
disabled?

I'm surprised that nobody else sees this crash given how easy it is
for me to reproduce.  BTW, the 3.11 kernel I made with 702821f
reverted has been humming along for days without issue.
