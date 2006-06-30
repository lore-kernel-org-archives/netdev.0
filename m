From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 15:59:14 -0400
Message-ID: <1151697554.5270.241.camel@jzny2>
References: <20060629085111.GY1376@postel.suug.ch>
	 <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch>
	 <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch>
	 <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch>
	 <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch>
	 <1151678118.5270.45.camel@jzny2>  <20060630163229.GH14627@postel.suug.ch>
	 <1151687977.5270.91.camel@jzny2>  <44A5606B.5080003@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:18652 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750784AbWF3T7S
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 15:59:18 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FwP98-0001Hm-G0
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 15:59:22 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44A5606B.5080003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 19:33 +0200, Patrick McHardy wrote:
> jamal wrote:
> > You are attempting to change architecture (which works just fine) in the way you 
> > think it should work - and then point to something as a bug because it 
> > doesnt work the way you think it should work. 
> > This is a problem not just with you BTW, but with Patrick as well (although he has 
> > gotten better lately). There is a huge difference for example when dealing with 
> > Herbert. My approach in situations like this, which you dont have to follow, is 
> > to ask first what the intent was then if i dont like the intent try to convince the
> > owner that there maybe better ways. Or why they are wrong. 
> 
> Well, I thought I stay out of this, but since you mention me ..
> 

I think you will add value to the discussion ;->
Regardless, we need to settle these kind of issues so we can work better
together. A while back i said was going to bring some of these issues at
the next netconf - but since the discussion is happening already, lets
do it here. Maybe we should take this discussion privately?

> I also had the feeling it has gotten easier working with you lately,

The feeling is mutual. 

> but I can understand Thomas's pain, I had the same thoughts more than
> once. Your code often does have an enormous amount of bugs and
> whitespace and other stylistic problems and working with you can be
> challenging for multiple reasons, for example having to go to endless,

One thing is clear in my mind at least (and i have said it several
times): I am not as good at the semantics as either yourself or Thomas
or Dave or Acme etc but i have tons of other things that compensate for.
Probably "not as good" is not the best  description  - rather my brain
cells put less respect on the stylistic commas than they do on the
message. Perhaps it's dylexsia or me trying to subconsciouly maximize my
time. If you push me hard, however, i will get close to do just as a
good job as you;->  Still, cant live without you guys! 
 
I would describe the majority of the fixes you have sent against me to
fall into the stylistic category and into fixing TheLinuxWay (i.e same
bug in multiple places and files). This is not to say i am not at fault,
or there havent been issues which made me wonder, but we may have
different metrics of what bugs i would call my mom and say "Mom, I just
fixed enormous amount of bugs". 
[As an example if you went hunting around the kernel, you will find a
lot of things that dont totally conform to lindent rules. You could
literally send 100s of patches].
Perhaps it is the language usage that puts us at odds at times.

> often entirely pointless discussions for obvious fixes, 

You may see it that way - I dont and so when that happens it is not by
any means to engage in a meaningless debate. 
The discussions are typically of the same nature as i just had with
Thomas (just a simple one line change in ifb which looked very
"obvious").

The way it goes is that there is a certain assumption made, and a
solution is suggested in the form of a patch. Accepting such a patch
(which i once in a while dont even get to see until it is in) means a
lot of the other assumptions get invalidated and is followed by tons of
"bug fixes". This has happened a few times to me. And once or twice i
have bitched because i ended having to support some user for days with
the wrong view.

> especially if you're already pissed by noticing 50 bugs at once. 

I dont get agitated by 100 patches which fix stylistic issues or real
bugs - although i would have preferred to see the non-obvious first
before they go in just in case or at least CCed on submission.
Where i get irritated, depending on how my day is going: when i see even
a single patch laded with implicit insults. It comes out to me as
unnecessary arrogance and immaturity. It may not be intentional use of
language, but thats how it comes out. 

> The reason why you
> might be able to work better with Herbert is IMO that he usually
> doesn't touch what you seem to feel is "your area". 

I think it's the maturity approach perhaps. With Herbert, it ends up
being about solving the problem; there are always moments of tension and
what may appear as endless discussion (look at the thread on
qdisc_is_running), but in the end it doesnt turn out into a high school
debate to prove one is better than the other. So maybe it is the mutual
respect and maturity in the discussion. 

In regards to "areas", you may be right; i cross more into Herberts path
than he does mine.
My reaction in this may be related to the way i treat other people and
my expectations:
When i submit patches to i would make sure i cc people who i think have
stakes or better insight in that area even if they seem irrelevant.
In-fact i may have even private conversations with them first if they
are large patches.
As an example i would make sure i cc you if i had some netfilter issues
or Herbert when i submit ipsec patches and we would have a gazillion
discussions which would sometimes result in the patches being totally
re-written. It doesnt make me happy all the time (especially when i have
to drop patches), but in the end it made me work better with that person
and removes doubt in my mind that i have missed something. Unfortunately
this approach (even in non-linux areas) is a lot of times
taken for a weakness.

cheers,
jamal

> Besides that, I
> never changed anything in your architecture, only fixed massive
> amounts of bugs.
> 



