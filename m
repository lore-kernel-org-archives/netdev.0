From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Sat, 12 Apr 2008 10:06:05 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804120810030.32619@wrl-59.cs.helsinki.fi>
References: <47FEADCB.7070104@rtr.ca> <20080410.172453.44434205.davem@davemloft.net>
 <47FEB062.3020003@rtr.ca> <20080410.173911.179180620.davem@davemloft.net>
 <47FEBDAA.7010305@rtr.ca> <Pine.LNX.4.64.0804110849520.28360@wrl-59.cs.helsinki.fi>
 <47FF6555.50004@rtr.ca> <20080411143537.GA27874@2ka.mipt.ru> <47FFE33C.1000707@imap.cc>
 <20080411222536.GA25893@2ka.mipt.ru> <47FFF2E5.9040807@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Mark Lord <lkml@rtr.ca>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, Jeff Garzik <jeff@garzik.org>,
	rjw@sisk.pl, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60310 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758580AbYDLHGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 03:06:09 -0400
In-Reply-To: <47FFF2E5.9040807@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Apr 2008, Tilman Schmidt wrote:

> On Sat, 12 Apr 2008 02:25:36 +0400, Evgeniy Polyakov wrote:
> > On Sat, Apr 12, 2008 at 12:16:28AM +0200, Tilman Schmidt (tilman@imap.cc) wrote:
> >> So I was right after all? Bug reports from people who (for whatever
> >> reason, including having to earn their living) cannot do a bisect are
> >> not welcome?
> > 
> > You got it wrong.
> 
> Did I really? Let's see ...
> 
> > If bug is subtle and developers can not reproduce it, there are only two
> > ways out of the problem: to help developers or not to help.
> > 
> > In the latter case bug report is useless (except that to show that it
> > exists, since practically no one can fix it until some new details
> > added).
> 
> Looks like you're saying I was right after all. Useless bug reports
> shouldn't be submitted.

...No, useless bug reports don't lead to a solution, ie., that particular 
bug won't get fixed as a result of the report! That's what these people 
are trying to say. Sure the point of bug reports is to get the bugs fixed,
don't you think? :-/ ...Or do you thing it's only secondary to get them 
fixed.

> So please answer this simple question: If I know beforehand that I won't
> have the time to do a bisect (or other similarly time-consuming task the
> maintainers might ask from me), should I report the bug, or should I
> keep my knowledge to myself?
> 
>
> > Bisection was just an example of the help, reporter can provide.
> 
> Sure. It's not about bisection specifically, but about the time a
> reporter is able to invest in addition to what went into the report
> already. But bisection is is a good example, because it's the most
> time-consuming of all the tasks routinely asked from bug reporters.

I'm asking the same thing from you as I did from Mark (it still remains 
unanswered)... What's your suggestion, how should we have solved this 
particular case? Do you join those that ask for developers to "invest" 
time to repeatedly go through the commits that are not guilty? ...One 
would never find the solution by that method :-/.

Yes, I'm fine that you don't want to help (or would want but cannot help 
like have been with many of nearly impossible to reproduce bugs with TCP 
lately) but the sole consequence is that the bug remains unsolved, it's 
plain simple. That's until somebody else is affected and reports and we 
get the necessary information. Or alternatively somebody just reads the 
offending code (possibly much later) and begins to wonder why there's this 
particular thing missing there (this is in fact not related to the bug 
reports at all, many bugs are found this way but it's not a thing one
can force to happen in a timely manner :-)).

> > If you can not proceed with what was suggested, then do
> > not piss anyone off because you were told to do something to help.
> 
> If a polite "sorry, I don't have the time" already counts as pissing
> off, the only choice left is to avoid the situation in which I'd have to
> say that. IOW, don't report bugs if I don't have the time to follow
> through. Again: if that is what you want, I have no problem with it.

Please reread the thread, this couldn't be farther from the truth...

...Dave had suggested Mark would have to bisect, I suppose this was after 
founding out that there wasn't anything particular that should cause this 
kind of behavior, or at least he couldn't find anything even suspicious 
looking. Mark, with rather demanding tone, was _also_ asking for that 
"somebody" who did all those TCP fin/closing changes (that would be me) to 
be responsible over them, ie., those parts that Dave had checked and found 
not suspicious (and bisect also proved them innocent later on). Yes, I 
then went through that "mountain of commits" which Mark "was not willing 
to do" himself. I invested the time even after Dave had also come to the 
same conclusion as I again did, that there is nothing wrong with the 
particular parts of the TCP. Funny, since it seems that even Mark himself 
had come to that same conclusion as both Dave and myself then came (though 
I cannot really speak for him). So I was third one to check those parts 
which were then found not guilty, would I be angry about it, I would call 
that plain waste of time :-). Please note too that I would have gone 
through them without his remarks as well to just check the thing I already 
knew.

So what's the problem with that. The thing that Mark wasn't very willing 
to go through that "mountain of commits" and made some accusions that one 
shouldn't ask user to do that, yet he was doing the same thing, asking for 
me to go through that "mountain of commits". I don't find that as polite
as you do (and maybe you don't honestly either), especially as that was 
_already done by Dave_, yet it wasn't enough for him.


[...doctor part snipped...]

> A better analogy would be if I see an object lying on the highway, and I
> stop at the next service area to call the police and alert them about
> the possible danger. If they'd ask me to drive back to the place where I
> saw it in order to describe precisely where it lay and what it looked
> like, I think I might indeed become a bit upset.

But you would feel qualified to tell how the police/doctor must handle 
it? ...That was the main problem.


To conclude I moved this your case down here...

> This question is not theoretical. It's a situation I find myself in
> quite regularly, because I allow myself the luxury of building most rc
> kernels and even the odd mm kernel just for fun even though I have a
> daytime job and a family to feed. It would be quite easy to look the
> other way if I encounter a problem in one of those, hoping someone else
> with more time on his or her hands will also come across it and report
> it. So far my conscience told me not to do that. But if reporting it
> without being able to follow up on it is considered useless then my
> conscience was apparently wrong. Just say the word, and I'll stop what
> I'm doing. I'll have no problem finding other things to do with my time.

It's perfectly fine that you report bugs, even with little time :-). But 
then if you are asked to do something that is necessary to help developers 
and you are not willing to do that, please don't start adding demands 
(it might actually be quite hard to restrain oneself from adding hidden 
"attacks" to wording, at least for me). Also we have to then accept the 
concequences, ie., the bug won't get fixed because of that report 
(unless something comes up later which connects the pieces).

> PS: I'll shut my big mouth now. The topic has been beaten to death.

I thought the same earlier, but I want to try to correct the misunderstand
you are tryng really hard to get here :-).


-- 
 i.
