From: Jeff King <peff@peff.net>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 23 Apr 2009 16:09:32 -0400
Message-ID: <20090423200932.GB3056@coredump.intra.peff.net>
References: <20090423184319.GB2756@ami.dom.local> <Pine.LNX.4.64.0904232103390.13488@ask.diku.dk> <20090423191455.GC2756@ami.dom.local> <Pine.LNX.4.64.0904232136040.13796@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Radu Rendec <radu.rendec@ines.ro>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>, git@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <git-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0904232136040.13796@ask.diku.dk>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2009 at 09:47:05PM +0200, Jesper Dangaard Brouer wrote:

>>> Is there any easy git way to figure out which release this commit got
>>> into?
>>
>> I guess git-describe, but I prefer clicking at the "raw" (X-Git-Tag):
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff_plain;h=f4c1f3e0c59be0e6566d9c00b1d8b204ffb861a2
>
> I think I prefer the command line edition "git-describe".  But it seems  
> that the two approaches gives a different results.
> (Cc'ing the git mailing list as they might know the reason)

You want "git describe --contains". The default mode for describe is
"you are at tag $X, plus $N commits, and by the way, the sha1 is $H"
(shown as "$X-$N-g$H").

The default mode is useful for generating a unique semi-human-readable
version number (e.g., to be included in your builds).

-Peff
