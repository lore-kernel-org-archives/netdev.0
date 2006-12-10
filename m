From: Herbert Poetzl <herbert@13thfloor.at>
Subject: Re: [Devel] Re: Network virtualization/isolation
Date: Sun, 10 Dec 2006 03:21:00 +0100
Message-ID: <20061210022100.GA6846@MAIL.13thfloor.at>
References: <m1k617u10x.fsf@ebiederm.dsl.xmission.com> <200612041900.42768.dim@openvz.org> <m1odqj8uyt.fsf@ebiederm.dsl.xmission.com> <4576AF68.2070604@sw.ru> <20061206183036.GA16927@MAIL.13thfloor.at> <m164cm2m9u.fsf@ebiederm.dsl.xmission.com> <20061209035002.GA11747@MAIL.13thfloor.at> <20061208221348.b263e3c2.akpm@osdl.org> <20061209063517.GG11747@MAIL.13thfloor.at> <457B39E6.7070404@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	hadi@cyberus.ca, Linus Torvalds <torvalds@osdl.org>,
	Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL.13thfloor.at ([213.145.232.33]:49746 "EHLO
	MAIL.13thfloor.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759460AbWLJCVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 21:21:01 -0500
To: Kir Kolyshkin <kir@openvz.org>
Content-Disposition: inline
In-Reply-To: <457B39E6.7070404@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 10, 2006 at 01:34:14AM +0300, Kir Kolyshkin wrote:
> Herbert Poetzl wrote:
> >On Fri, Dec 08, 2006 at 10:13:48PM -0800, Andrew Morton wrote:
> >  
> >>
> >>It's actually happening quite gradually and carefully.
> >>    
> >
> >hmm, I must have missed a testing phase for the
> >IPC namespace then, not that I think it is broken
> >(well, maybe it is, we do not know yet)
> >

> You have announced at LKML that Linux-VServer now uses the 
> stuff that was merged in 2.6.19-rc1, haven't you? 

yes, correct, and we already fixed several issues
the changes caused, both in handling as well as
functionality

> I suppose that means you are  using IPC namespaces from 
> mainstream? 

yes, we do 

> Isn't that considered testing? 

of course it is testing, but it is already in
mainstream, and for my part, I wasn't able to
provide feedback from testing yet ...

> Or you don't test Linux-VServer?

we do the same testing you folks do IIRC
(i.e. some secret test procedure which takes
roughly a week or so, after which we can tell
that everything works as expected :)

> Please clarify, I'm a bit lost here.


> Speaking of OpenVZ, as Kirill Korotaev said before we have 
> backported all that to 2.6.18 back in September 

nice, but what relevance has that for 2.6.19?

> and are using it since then.

cool, how much feedback regarding IPC did you get
since then?

> And yes, we found a bug in IPC namespaces, and fix from 
> Pavel Emelyanov has made it to 2.6.19-rc5 (see commit 
> c7e12b838989b0e432c7a1cdf1e6c6fd936007f6 to linux-2.6-git).

it's good that some bugs have been found, but
of what relevance is that for testing mainline
patches?

 - typical linux users will only excercise a 
   small fraction of the new code, if at all
 - virtualization solutions like OpenVZ and
   Linux-VServer add their custom modifications
   and/or adjustments, and serve a much smaller
   userbase
 - I haven't seen any test suites or similar
   for the spaces

so it all boils down to waiting for somebody to
stumble over an issue, which then will get fixed
just that the number of folks testing that is
quite small compared to 'other' mainline pathes

anyway, originally I was just answering to an
email pushing for 'fast' inclusion, which I do
not consider a good idea (as I already stated)

best,
Herbert

