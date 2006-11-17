From: jamal <hadi@cyberus.ca>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Fri, 17 Nov 2006 14:47:54 -0500
Message-ID: <1163792874.5219.49.camel@jzny2>
References: <45541757.90800@hp.com> <20061110173642.GL8693@postel.suug.ch>
	 <20061113072347.GB1892@ff.dom.local> <200611130908.18644.paul.moore@hp.com>
	 <1163427457.6825.14.camel@jzny2>  <4558D061.5090802@hp.com>
	 <1163768753.5107.11.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:43154 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S933579AbWKQTr7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 14:47:59 -0500
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Gl9gy-0006RT-CI
	for netdev@vger.kernel.org; Fri, 17 Nov 2006 14:48:04 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <1163768753.5107.11.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-17-11 at 08:05 -0500, jamal wrote:

> i will review the doc as soon as i am done with that.

I glanced at the doc over lunch. I will give you high level views first
and later on today or tomorrow i will give you a lot more pointed
opinions.

#1. I think the content layout has improved over the previous doc. So
good stuff.
Something still bothers me though; whether there is too much theory or
verbosity (not that this long email has any of those
characteristics;->). I am wondering if that affects usability. As a
litmus test, what would be the answer to the question:
"If i didnt know anything about generic netlink, how long do i need to
spend and immediately start programming?"
I dont think it is 5 minutes. Can we make it a 5 minute effort?

I think this is partially my fault because thats how i laid out the
original doc (and always is my style) - but you added more;->

Heres a thought:

** lay it out is to have two sections:

I. A LinuxWay section (others call it genetic programming!)

a) "heres an example for the kernel and heres the controller from user
space"
b) "heres what all different fields mean"

II. Here are all the nitty gritty details your mother never told you.

What this means is someone can immediately jump to Ia) do it the
LinuxWay(tm). When in doubt will read Ib) and when in further doubt will
read II.
[Actually Andrew Morton contented that nobody needs more than section I
when i first posted the doc].

I know this is a big change, so it will depend on how much time you
have. I also think people may be happy with it in its current form. It
would be nice to get feedback from someone who has used it.

2) Hey - you got rid of foobar[1] and googah ;-> I love those terms.
No big deal - you own the doc now, so you can get away with things like
that ;->

3) Why not create a references section at the end and move all the
references you have scattered every there instead? 

4) Terminology is still confusing even to me. We most definetely need
such a section. For example, I dont like the term "family" to descrive
those boxes that sit in the kernel. But i dont know what else to call
them. Also looking closely at Thomas' introduction of the thing called
nla_policy - it really oughta have been called attribute "property".
To add to this chaos - you introduced something you call a "channel". A
little confusing although sounds right ;-> I think the previous doc had
attempted something like a section on terms introduced by Balbir. But
you may have gotten rid of it.

5) For registration of commands and families, you dont show the user
handling return codes which could be errors. If this doc becomes
scripture it could mean trouble. Just a cutnpaste from the original doc
should suffice. 

6) There is still a lot of "content" for theory mostly that is missing.
I noticed you dont have async events, discovery etc. And there are still
a few ideas i would like to discuss with Thomas and send patches for
later.
So keep me as a coauthor - it will keep me on the hook for now; i will
bail out the moment i think it is complete.

hope this helps. 

cheers,
jamal

[1] http://en.wikipedia.org/wiki/Foobar

