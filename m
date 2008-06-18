From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Wed, 18 Jun 2008 14:25:28 -0700
Message-ID: <48597D48.5090604@intel.com>
References: <20080617083220.GA11393@elte.hu>
 <20080617.020840.169830916.davem@davemloft.net>
 <20080617092706.GB20621@elte.hu>
 <20080617.022909.173003136.davem@davemloft.net>
 <20080617093929.GA10334@elte.hu> <48595910.8000905@intel.com>
 <20080618200805.GA18756@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vgusev@openvz.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl, mcmanus@ducksong.com,
	ilpo.jarvinen@helsinki.fi, kuznet@ms2.inr.ac.ru, xemul@openvz.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	Arjan van de Ven <arjan@linux.intel.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:41480 "EHLO
	vms046pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754540AbYFRVcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 17:32:41 -0400
In-reply-to: <20080618200805.GA18756@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Kok, Auke <auke-jan.h.kok@intel.com> wrote:
> 
>>> Any ideas about what i should try next?
>> have you tried e1000e?
> 
> will try it.
> 
> But even it if solves the problem it's a nasty complication: given how 
> many times i have to bisect back into the times when there was only 
> e1000 around, how do i handle the transition? I have automated bisection 
> tools, etc. and i bisect very frequently.
> 
> It's a real practical problem for me: if i have E1000E=y in my .config 
> and go back to an older kernel, i lose that .config setting in 'make 
> oldconfig'. Then when the bisection run happens to go back into the 
> E1000E times, 'make oldconfig' picks up E1000E with a default-off 
> setting - and things break or work differently.
> 
> no other Linux driver i'm using forces me to do that and i rely on many 
> of them and i rely on proper 'make oldconfig' behavior on a daily basis. 
> Until now i was able to do automatic bisection back for _years_, to the 
> v2.6.19 times. You broke that.
> 
> And that's just one driver out of thousands of Linux drivers. Imagine 
> what happened to bisectability and migration quality if every driver 
> version update was this careless about its installed base as 
> e1000/e1000e.
> 
> The e1000 -> e1000e migration it was not only done in an incompetent, 
> amateurish way, you also ignored real feedback and that combined 
> together is totally lame and inacceptable behavior in my book. You 
> should not expect praise and roses from me as long as you do stupid 
> things like that.

where were you when we discussed this? We took over a year and a half to get to a
final plan and many people responded and provided feedback. In the end Jeff Garzik
and many community members suggested a plan and this is what I implemented. In not
a single way did I force anything down anyones throat. I did exactly what the
community wanted me to do, and in the way that it seemed best by everyone.

You only complain and do not provide a single solution to your problem. Your
continued screaming and whining is totally not productive nor constructive at all,
and frankly is insulting since you completely ignore the fact that we worked with
the the community more than two-year to come to some maintainable situation. All
you do is complain. Direct your problems to the network stack and driver
maintainers since they approved and worked with me to implement the changes.

*** NOTE: I NO LONGER MAINTAIN E1000/E1000E, nor do I represent them or speak for
them. ***

I frankly suggested that you try e1000e because this might provide valuable
information for the people who are taking this ingrateful job after me. This was
meant in a productive and constructive way.

your flame is totally inappropriate and unprofessional. Either come up with a
solution or start working on one, like I did when I took the much hated job as
e1000 maintainer.

I am totally open to suggestions and if needed I will work with the current
e1000/e1000e maintainers on working something out if I see a better solution than
the current situation. Until I see such a thing I can't do much else than ignore
your childish whining.

Auke
