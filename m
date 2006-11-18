From: jamal <hadi@cyberus.ca>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Sat, 18 Nov 2006 12:06:59 -0500
Message-ID: <1163869619.5221.43.camel@jzny2>
References: <45541757.90800@hp.com> <20061110173642.GL8693@postel.suug.ch>
	 <20061113072347.GB1892@ff.dom.local> <200611130908.18644.paul.moore@hp.com>
	 <1163427457.6825.14.camel@jzny2> <4558D061.5090802@hp.com>
	 <1163768753.5107.11.camel@jzny2> <1163792874.5219.49.camel@jzny2>
	 <455E4B67.9020703@hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:32474 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1754410AbWKRRHC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Nov 2006 12:07:02 -0500
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GlTej-0008GD-1I
	for netdev@vger.kernel.org; Sat, 18 Nov 2006 12:07:05 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <455E4B67.9020703@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-17-11 at 18:53 -0500, Paul Moore wrote:
> jamal wrote:

> I think we are best off punting on the userspace as there a multiple ways to do
> it: use good ole fashioned socket calls, the libnl library, or some other way
> that hasn't been written yet.  Besides, Thomas already has some pretty good
> userspace documentation written for libnl; no sense in duplicating that effort.
> 

That has been my thinking as well. Looking at just the comments in the
code for the attribute stuff I think Thomas has done an excellent job in
documenting.
I havent looked at libnl in many moons (and dont have time at the
moment) - but it would be the right thing for a newbie/usability
approach.
In my tutorial I am not going to use it mostly because of lack of time
to figure out things (have to get out about 100 slides done by monday).
I already know how to use libnetlink and i have already added patches to
iproute2 for genetlink - so i am going to use those.
I will send you the tutorial so you can see what i mean.

> That said, there is a kernel space example and a field breakdown; did that look
> okay?  

It did. Just the little nitpicks i mentioned (like error checks etc). I
will stare at it some more later.

> If the content is good but the layout is off we can always move it up
> closer to the top of the document.  If the content needs work lets deal with
> that first ...
> 

I think moving it up first may make it more usable. If i find this doc,
cutnpaste, change variable names, load it, refine it further to do what
i want ... that would be ideal.

> Well, if we are talking about *needs* then nobody really needs more than the
> source code.  

I am not entirely sure i buy that anymore these days.
[The shock i had at some point is that the majority of linux users are
not subscribers to "the code is the message" philosophy. This was a
shock to me because the crowd i typically associate with always delivers
that message "Look at the source and you shall be healed"].

> IMHO the main reason for documentation is to help speed along the
> understanding of the code so it becomes more accessibile.  I can see their being
> value for including both section I and section II material in the document.
> 

sure, sure.
And in the complex case, source is useless if you dont know what is
being coded. 
  
> > I know this is a big change, so it will depend on how much time you
> > have. I also think people may be happy with it in its current form. It
> > would be nice to get feedback from someone who has used it.
> 
> Well, it's Friday night and I've got a big football game to watch tommorrow so
> I'm probably not going to devote much time to this until Monday.  

Take it easy, no rush.

> Let's see what
>  other people have to say in the meantime.  We can always just submit/post it
> and play with it as time permits.
> 

indeed.

> One of the main reasons I wanted to post my changes is because I found your
> original document helpful when writing NetLabel but I didn't know about when I
> started because it wasn't located in the usual places (I had to pick it out of
> the mailing list archives).  I think having a Generic Netlink document in
> Documentation/ and/or on the OSDL network wiki is a good thing - even if it
> isn't perfect.
> 

I tend to be conservative when pushing to the kernel(you should see the
patches i am sitting on;->). But if you are brave, go ahead and submit
it. Perhaps you can put the doc somewhere, and send a url patch to the
kernel and then keep updating the web version.

> Don't take it personally, it's just step one in my master plan to remove all
> references too "googah" from the english language.  Muwahahaha!
> 

hehe. That would be hard unless you get rid of certain cartoon
characters ;->

> I tend to like the actual references closer to the referring text (I dislike
> scrolling) but I'm not too hung up on this, I can move it.

Your mileage may vary. Your call - The formal way is you have them at
the end.

> Yeah, I stuggled with that the entire time I was writing that draft.  I'm still
> not entirely happy with it either but I decided that I was tired of worrying
> about it so I just sent it out.
> 
> I don't remember a section on terminology in your original doc, but I'll go back
> and check.
> 

If it is not there, I suggest just adding it in II.

> Hey, anybody who sends me text that doesn't include the phrase "Justin
> Timberlake Rocks" gets to be a {co}author.  

[Is Justin Timberlake the fella who got the FCC involved in Janet
Jacksons mammary glands? If, yes, he rocks!]

> I'm just trying to keep the document
> alive.
> 

A noble effort. And i dont want to stress you with more work - As it is
it is not bad, it could just be better ;-> (famous last words?)


> > [1] http://en.wikipedia.org/wiki/Foobar
> 
> My favorite wikipedia page -> http://en.wikipedia.org/wiki/Mad_Scientist

Hey, how did my picture get there? ;->

cheers,
jamal

