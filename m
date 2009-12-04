From: Caleb Cushing <xenoterracide@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Fri, 4 Dec 2009 13:28:26 -0500
Message-ID: <81bfc67a0912041028w16668d0cx4da04bee989eef4a@mail.gmail.com>
References: <81bfc67a0911232217n41b9ac02w3b7770b789e5d209@mail.gmail.com>
	 <20091124111946.GA7883@ff.dom.local>
	 <81bfc67a0911250606k1ec76354n217da9ca20b3517c@mail.gmail.com>
	 <20091125191105.GA3167@ami.dom.local>
	 <81bfc67a0911271007o1fb8f8c2vdd36e8585280e4da@mail.gmail.com>
	 <20091127213640.GA2611@ami.dom.local>
	 <81bfc67a0911271435g4106652bpe8c9ea07893d0ebd@mail.gmail.com>
	 <20091127224206.GA3350@ami.dom.local>
	 <81bfc67a0912031749y15faed66s9c8a924684c97a19@mail.gmail.com>
	 <20091204090524.GB6478@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:64785 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbZLDS2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 13:28:19 -0500
In-Reply-To: <20091204090524.GB6478@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2009 at 4:05 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> On Thu, Dec 03, 2009 at 08:49:17PM -0500, Caleb Cushing wrote:
>> >
>> > modprobe -r e1000e
>> > modprobe e1000e IntMode=0
>> >
>> > Jarek P.
>> >
>> tested on kernel behaving properly no change. what do these modes do?
>
> e1000e by default uses MSI-X interrupts if possible, which are most
> modern. If there are some problems IntMode lets us try older types,
> so I rather meant it for the misbehaving kernel.
>
>>
>> I've installed a 10/100 linksys nic into my system. it appears to be
>> working fine on a bad kernel (2.6.32-final tested and for sure
>> verified). I've only tested it once though. my laptop died so direct
>> connection between that won't work. can I test between these 2 nics?
>> (suppose no real reason why not) but what should I proceed with at
>> this point?
>
> If you have it fixed easily with another nic you should first
> reconsider if this debugging is worth of your time. Of course it's
> could be very useful for the kernel (unless it's a hardware fault),
> but on the other hand this is a popular nic, tested by many people.

trying to figure out if it's hardware, I wish I'd figured that out a
month ago because dell would have been shipping me a new mobo at that
point... oh well... I'm starting to think it is but given the age of
the computer... (just over 1 year now) I'm not happy about that. my
nic is a 10/100 card the e1000e is obviously gigabit though I don't
think I've a need (or network) for the gigabit atm
-- 
Caleb Cushing

http://xenoterracide.blogspot.com
