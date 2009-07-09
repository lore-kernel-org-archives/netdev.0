From: Joao Correia <joaomiguelcorreia@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Thu, 9 Jul 2009 22:19:34 +0100
Message-ID: <a5d9929e0907091419j2e4aefbdrc845b3e158982539@mail.gmail.com>
References: <200907031326.21822.andres@anarazel.de> <200907091728.23367.andres@anarazel.de>
	<alpine.LFD.2.00.0907091801130.24704@localhost.localdomain>
	<200907091846.37926.andres@anarazel.de> <alpine.LFD.2.00.0907091943290.2768@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andres Freund <andres@anarazel.de>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:61585 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754137AbZGIVT6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 17:19:58 -0400
In-Reply-To: <alpine.LFD.2.00.0907091943290.2768@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 9, 2009 at 6:44 PM, Thomas Gleixner<tglx@linutronix.de> wro=
te:
> Andres,
>
> On Thu, 9 Jul 2009, Andres Freund wrote:
>
>> On Thursday 09 July 2009 18:01:56 Thomas Gleixner wrote:
>> > Andres,
>> >
>> > On Thu, 9 Jul 2009, Andres Freund wrote:
>> > > On Thursday 09 July 2009 16:28:05 Thomas Gleixner wrote:
>> > > > Please test them separate from each other. The one I sent in t=
his
>> > > > thread was just for narrowing down the issue, but I'm now quit=
e sure
>> > > > that they really hit the issue which is addressed by the hrtim=
er
>> > > > patch.
>> > >
>> > > No crash yet. 15min running (seconds to a minute before).
>> > >
>> > > Will let it run for some hours to be sure.
>> >
>> > Which one of the patches are you testing ?
>> Your "real" one, i.e. de907e8432b08f2d5966c36e0747e97c0e596810
>>
>> 1h30m now...
>
> Looks like I hit the nail on the head. Queueing it up for Linus.
>
> Thanks,
>
> =A0 =A0 =A0 =A0tglx
>

Confirmed working from me as well.

Thank you for your time,
Joao Correia
