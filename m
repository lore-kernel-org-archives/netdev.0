From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Fri, 11 Apr 2008 19:18:21 +0400
Message-ID: <20080411151821.GA32398@2ka.mipt.ru>
References: <47FEADCB.7070104@rtr.ca> <20080410.172453.44434205.davem@davemloft.net> <47FEB062.3020003@rtr.ca> <20080410.173911.179180620.davem@davemloft.net> <47FEBDAA.7010305@rtr.ca> <Pine.LNX.4.64.0804110849520.28360@wrl-59.cs.helsinki.fi> <47FF6555.50004@rtr.ca> <20080411143537.GA27874@2ka.mipt.ru> <47FF7CED.9090601@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	tilman@imap.cc, yoshfuji@linux-ipv6.org,
	Jeff Garzik <jeff@garzik.org>, rjw@sisk.pl,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Mark Lord <lkml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50335 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042AbYDKPS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 11:18:58 -0400
Content-Disposition: inline
In-Reply-To: <47FF7CED.9090601@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 10:59:57AM -0400, Mark Lord (lkml@rtr.ca) wrote:
> >If you do not care about bug, why do you ever bothered filling it?
> ..
> 
> Because I care, about Linux's reputation and performance.
> I care about basic networking operations, and knew that this bug
> would probably affect other applications once widely deployed.
> 
> I care about Linux.  That's why.

Blah-blah-blah, you care so much, that pissed people off which suggested
you how to really help Linux. And then you returned with besiect
results. You helped, but if you just cared, you had missed first part.

> >If you do not want to help fixing it ...
> 
> Where the hell did I *ever* say that?
> I did nothing but offer help, and respond quickly.

Citations:
> So you will likely need to bisect.

Or I can ignore it, like the net developers, since I have a workaround.
And then we'll see what other apps are broken upon 2.6.25 final release.

*Somebody* is responsible for those changes.
That particular *somebody* ought to volunteer some help here,
reducing the mountain of commits to a big handful or two.

-----

I can proceed - just reread a thread.

> The one thing I did not have time for initially,
> was a painstaking blunt instrument binary search of
> every commit since v2.6.24.

If you do not know math, binary search takes log2(N), so you
would only need to check at most around dozen commits. That's lot
of time to run 'git bisect good/bad', especially for man, who
"care about Linux".

> There are other ways to debug things and find the causes
> quickly, with less impact upon the reporters of bugs.

I know one. It is guessing.

I will start: did you start hearing voices after 2.6.24 upgrade?
Or did you observed meteorites hitting wires between you machines?

> The current generation of kernel "code submitters" here
> seems to have never learned those.  Bummer.

Next time I will ask soothsayer, she really knows how to debug network
bug with following description: "it worked before I changed a kernel
version. you have to return my puppets back".

-- 
	Evgeniy Polyakov
