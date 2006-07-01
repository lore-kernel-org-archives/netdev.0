From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sat, 01 Jul 2006 04:47:59 +0200
Message-ID: <44A5E25F.5020508@trash.net>
References: <20060629085111.GY1376@postel.suug.ch>	 <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch>	 <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch>	 <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch>	 <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch>	 <1151678118.5270.45.camel@jzny2>  <20060630163229.GH14627@postel.suug.ch>	 <1151687977.5270.91.camel@jzny2>  <44A5606B.5080003@trash.net> <1151697554.5270.241.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:10142 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750932AbWGACsC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 22:48:02 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151697554.5270.241.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2006-30-06 at 19:33 +0200, Patrick McHardy wrote:
> 
>>Well, I thought I stay out of this, but since you mention me ..
>>
> I think you will add value to the discussion ;->
> Regardless, we need to settle these kind of issues so we can work better
> together. A while back i said was going to bring some of these issues at
> the next netconf - but since the discussion is happening already, lets
> do it here. Maybe we should take this discussion privately?

Whatever helps resolving this, feel free to take this private if you
feel like it. I think I already managed to get along with our
differences quite well, but it was a hard path. Having friends that
use the same discussion tactics may have helped :) Just to clarify what
I'm saying below, I like you a lot personally, this is purely
"a work thing".

>>I also had the feeling it has gotten easier working with you lately,
> 
> 
> The feeling is mutual. 
> 
> 
>>but I can understand Thomas's pain, I had the same thoughts more than
>>once. Your code often does have an enormous amount of bugs and
>>whitespace and other stylistic problems and working with you can be
>>challenging for multiple reasons, for example having to go to endless,
> 
> 
> One thing is clear in my mind at least (and i have said it several
> times): I am not as good at the semantics as either yourself or Thomas
> or Dave or Acme etc but i have tons of other things that compensate for.
> Probably "not as good" is not the best  description  - rather my brain
> cells put less respect on the stylistic commas than they do on the
> message. Perhaps it's dylexsia or me trying to subconsciouly maximize my
> time. If you push me hard, however, i will get close to do just as a
> good job as you;->  Still, cant live without you guys! 

I think the things you did and which I struggeled with were right
to do, but what I don't understand is why you can't do it right
yourself. Software development has a lot of unpleasant parts,
but ignoring them can't be the right answer. In a shared project,
you should always remember that if you're not doing the work, some
else will have to.

> I would describe the majority of the fixes you have sent against me to
> fall into the stylistic category and into fixing TheLinuxWay (i.e same
> bug in multiple places and files). This is not to say i am not at fault,
> or there havent been issues which made me wonder, but we may have
> different metrics of what bugs i would call my mom and say "Mom, I just
> fixed enormous amount of bugs". 
> [As an example if you went hunting around the kernel, you will find a
> lot of things that dont totally conform to lindent rules. You could
> literally send 100s of patches].
> Perhaps it is the language usage that puts us at odds at times.

Sorry, absolutely not. The bugs I fixed were not just stylistic
things, although I still tried to take care of them where possible.
It was a huge number of bad bugs, even affecting kernels that didn't
even used the feature which introduced the bugs. As for "TheLinuxWay"
(I think I made my opinion on this clear already), cut-and-paste
of crappy code is not it. I'm always amazed how people can copy
crappy code without even thinking about it, when I copy code I usually
fix bugs in the code I copy _before_ doing so.

Language might of course still contribute to our misunderstandings.

>>often entirely pointless discussions for obvious fixes, 
> 
> 
> You may see it that way - I dont and so when that happens it is not by
> any means to engage in a meaningless debate. 
> The discussions are typically of the same nature as i just had with
> Thomas (just a simple one line change in ifb which looked very
> "obvious").

Sometimes you may be right, but despite all the lengthy discussions
we went through, I can't recall a single patch of mine that didn't
went in eventually. But OK, people are complaining about missing
clarification of intent, we're all sometimes guilty of that.
Still, starting a huge discussion about patches that clearly
move in the right direction like Thomas' one which started this
thread is frustrating to the submitter. Discussions about technical
matters should use technical, comprehensible arguments, and nothing
else. This basically means on of three things:

- Bad because it does ..
- Bad because this patch is better
- Applied

Vague expressions about "not good", "might be able to do better" or
"might create problems" without specification are not helpful as long
as they are vague. The point is: _show_ that the submitters argument
is wrong, and if it really is, that shouldn't be hard. This is
especially true if its not some random guy but someone familiar with
what he is changing. This thread is one of many examples.

> The way it goes is that there is a certain assumption made, and a
> solution is suggested in the form of a patch. Accepting such a patch
> (which i once in a while dont even get to see until it is in) means a
> lot of the other assumptions get invalidated and is followed by tons of
> "bug fixes". This has happened a few times to me. And once or twice i
> have bitched because i ended having to support some user for days with
> the wrong view.

Then the patch wasn't reviewed carefully enough. If assumptions get
invalidated, they need to be taken care of at the same time. It can
happen, and sometimes it even is intended (in case of not so well
understood code). But usually it is not and it is simply a bug,
and the submitter is guilty of not beeing careful enough.

>>especially if you're already pissed by noticing 50 bugs at once. 
> 
> 
> I dont get agitated by 100 patches which fix stylistic issues or real
> bugs - although i would have preferred to see the non-obvious first
> before they go in just in case or at least CCed on submission.
> Where i get irritated, depending on how my day is going: when i see even
> a single patch laded with implicit insults. It comes out to me as
> unnecessary arrogance and immaturity. It may not be intentional use of
> language, but thats how it comes out. 

Well, I admit that the insults (in the form of a description of all
the possible bugs, which is not really an insult) are sometimes
intentional, but usually only after I'm already really pissed by
having to take care of an enormous amount of somebody elses crap.
I think that is understandable human behaviour.

>>The reason why you
>>might be able to work better with Herbert is IMO that he usually
>>doesn't touch what you seem to feel is "your area". 
> 
> 
> I think it's the maturity approach perhaps. With Herbert, it ends up
> being about solving the problem; there are always moments of tension and
> what may appear as endless discussion (look at the thread on
> qdisc_is_running), but in the end it doesnt turn out into a high school
> debate to prove one is better than the other. So maybe it is the mutual
> respect and maturity in the discussion. 

Actually that thread was cleared up by Herbert nice and fast :) I too
enjoy working with him, but I think Herbert is a special case as his
arguments are in my opinion always perfectly clear, usually correct,
understandable and nicely formulated. He doesn't leave you much
choice :)

Probably also a bit of a language issue, I'm not able to express myself
as well as he is (especially not as friendly).

> In regards to "areas", you may be right; i cross more into Herberts path
> than he does mine.
> My reaction in this may be related to the way i treat other people and
> my expectations:
> When i submit patches to i would make sure i cc people who i think have
> stakes or better insight in that area even if they seem irrelevant.
> In-fact i may have even private conversations with them first if they
> are large patches.
> As an example i would make sure i cc you if i had some netfilter issues
> or Herbert when i submit ipsec patches and we would have a gazillion
> discussions which would sometimes result in the patches being totally
> re-written. It doesnt make me happy all the time (especially when i have
> to drop patches), but in the end it made me work better with that person
> and removes doubt in my mind that i have missed something. Unfortunately
> this approach (even in non-linux areas) is a lot of times
> taken for a weakness.

I always had the feeling you're beeing "protective", in the form of
pulling people in discussions not really related to the subject.

That was about it with my opinion on the matter, I think we will be
able to resolve this in a better way personally.

