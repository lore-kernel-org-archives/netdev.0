From: Paul Moore <paul.moore@hp.com>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Fri, 17 Nov 2006 18:53:11 -0500
Message-ID: <455E4B67.9020703@hp.com>
References: <45541757.90800@hp.com> <20061110173642.GL8693@postel.suug.ch>	 <20061113072347.GB1892@ff.dom.local> <200611130908.18644.paul.moore@hp.com>	 <1163427457.6825.14.camel@jzny2>  <4558D061.5090802@hp.com>	 <1163768753.5107.11.camel@jzny2> <1163792874.5219.49.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:25816 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1756040AbWKQXxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 18:53:13 -0500
To: hadi@cyberus.ca
In-Reply-To: <1163792874.5219.49.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> #1. I think the content layout has improved over the previous doc. So
> good stuff.
> Something still bothers me though; whether there is too much theory or
> verbosity (not that this long email has any of those
> characteristics;->). I am wondering if that affects usability. As a
> litmus test, what would be the answer to the question:
> "If i didnt know anything about generic netlink, how long do i need to
> spend and immediately start programming?"
> I dont think it is 5 minutes. Can we make it a 5 minute effort?
> 
> I think this is partially my fault because thats how i laid out the
> original doc (and always is my style) - but you added more;->
> 
> Heres a thought:
> 
> ** lay it out is to have two sections:
> 
> I. A LinuxWay section (others call it genetic programming!)
> 
> a) "heres an example for the kernel and heres the controller from user
> space"
> b) "heres what all different fields mean"

I think we are best off punting on the userspace as there a multiple ways to do
it: use good ole fashioned socket calls, the libnl library, or some other way
that hasn't been written yet.  Besides, Thomas already has some pretty good
userspace documentation written for libnl; no sense in duplicating that effort.

That said, there is a kernel space example and a field breakdown; did that look
okay?  If the content is good but the layout is off we can always move it up
closer to the top of the document.  If the content needs work lets deal with
that first ...

> II. Here are all the nitty gritty details your mother never told you.
> 
> What this means is someone can immediately jump to Ia) do it the
> LinuxWay(tm). When in doubt will read Ib) and when in further doubt will
> read II.
> [Actually Andrew Morton contented that nobody needs more than section I
> when i first posted the doc].

Well, if we are talking about *needs* then nobody really needs more than the
source code.  IMHO the main reason for documentation is to help speed along the
understanding of the code so it becomes more accessibile.  I can see their being
value for including both section I and section II material in the document.

> I know this is a big change, so it will depend on how much time you
> have. I also think people may be happy with it in its current form. It
> would be nice to get feedback from someone who has used it.

Well, it's Friday night and I've got a big football game to watch tommorrow so
I'm probably not going to devote much time to this until Monday.  Let's see what
 other people have to say in the meantime.  We can always just submit/post it
and play with it as time permits.

One of the main reasons I wanted to post my changes is because I found your
original document helpful when writing NetLabel but I didn't know about when I
started because it wasn't located in the usual places (I had to pick it out of
the mailing list archives).  I think having a Generic Netlink document in
Documentation/ and/or on the OSDL network wiki is a good thing - even if it
isn't perfect.

> 2) Hey - you got rid of foobar[1] and googah ;-> I love those terms.
> No big deal - you own the doc now, so you can get away with things like
> that ;->

Don't take it personally, it's just step one in my master plan to remove all
references too "googah" from the english language.  Muwahahaha!

> 3) Why not create a references section at the end and move all the
> references you have scattered every there instead? 

I tend to like the actual references closer to the referring text (I dislike
scrolling) but I'm not too hung up on this, I can move it.

> 4) Terminology is still confusing even to me. We most definetely need
> such a section. For example, I dont like the term "family" to descrive
> those boxes that sit in the kernel. But i dont know what else to call
> them. Also looking closely at Thomas' introduction of the thing called
> nla_policy - it really oughta have been called attribute "property".
> To add to this chaos - you introduced something you call a "channel". A
> little confusing although sounds right ;-> I think the previous doc had
> attempted something like a section on terms introduced by Balbir. But
> you may have gotten rid of it.

Yeah, I stuggled with that the entire time I was writing that draft.  I'm still
not entirely happy with it either but I decided that I was tired of worrying
about it so I just sent it out.

I don't remember a section on terminology in your original doc, but I'll go back
and check.

> 5) For registration of commands and families, you dont show the user
> handling return codes which could be errors. If this doc becomes
> scripture it could mean trouble. Just a cutnpaste from the original doc
> should suffice. 

Good point, I included it in the other examples but not that one - I'll fix it.

> 6) There is still a lot of "content" for theory mostly that is missing.
> I noticed you dont have async events, discovery etc. And there are still
> a few ideas i would like to discuss with Thomas and send patches for
> later.

Yep, I was trying to get it fairly small so people wouldn't be afraid by the
length of the document.  However, if we try to partition the document into two
sections then it's probably won't be too bad.

> So keep me as a coauthor - it will keep me on the hook for now; i will
> bail out the moment i think it is complete.

Hey, anybody who sends me text that doesn't include the phrase "Justin
Timberlake Rocks" gets to be a {co}author.  I'm just trying to keep the document
alive.

> [1] http://en.wikipedia.org/wiki/Foobar

My favorite wikipedia page -> http://en.wikipedia.org/wiki/Mad_Scientist

-- 
paul moore
linux security @ hp
