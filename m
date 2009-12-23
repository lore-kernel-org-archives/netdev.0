From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 17:27:14 -0600
Message-ID: <4B32A752.1020709@codemonkey.ws>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <4B3248F9.5030504@gmail.com> <20091223171052.GI20539@basil.fritz.box> <4B3250BC.50203@gmail.com> <alpine.LFD.2.00.0912230922290.6879@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:58320 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756172AbZLWX1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:27:17 -0500
In-Reply-To: <alpine.LFD.2.00.0912230922290.6879@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/2009 11:29 AM, Linus Torvalds wrote:
>
>
> On Wed, 23 Dec 2009, Gregory Haskins wrote:
>>>
>>> And upstream submission is not always like this!
>>
>> I would think the process would come to a grinding halt if it were ;)
>
> Well, in all honesty, if it had been non-virtualized drivers I would just
> have pulled. The pull request all looked sane, the diffstat looked clean
> and non-intrusive, and I had no problems with any of that.
>
> But the virtualization people always argue about the fifty-eleven
> different ways of doing things, and unlike real drivers - where the actual
> hardware places constraints on what the heck is going on - virtualization
> people seem to revel in making new interfaces weekly, and tend to be only
> incidentally limited by hardware (ie hardware interfaces may limit some
> _details_, but seldom any higher-level arguments).
>
> So when I see another virtualization interface, I want the virtualization
> people to just argue it out amongst themselves.

Actually, this sentiment is really the basis of this whole discussion. 
KVM is the product of learnign the hard way that that inventing 
interfaces just because we can is a total waste of time.

Our current I/O infrastructure is based on PCI devices that we can 
emulate efficiently.  They look, feel, and taste like real hardware 
devices.  We try to be as boring as humanly possible and so far, it's 
worked out extremely well for us.

> Thanks to the virtue of me
> personally not caring one whit about virtualization, I can stand back and
> just watch the fireworks.

That's ashame, because I wish more people with a practical sentiment 
cared about virtualization to discourage the general silliness that 
seems to be all too common in this space.

Regards,

Anthony LIguori
