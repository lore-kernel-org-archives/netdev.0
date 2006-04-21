From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Fri, 21 Apr 2006 11:56:37 -0700
Message-ID: <20060421115637.3ca7cfce.akpm@osdl.org>
References: <20060421010809.6c3cfc34.akpm@osdl.org>
	<4807377b0604211015j16b40cccpe215668f8fdcfc24@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml@jawad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53131 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750807AbWDUS5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 14:57:41 -0400
To: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0604211015j16b40cccpe215668f8fdcfc24@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Jesse Brandeburg" <jesse.brandeburg@gmail.com> wrote:
>
> On 4/21/06, Andrew Morton <akpm@osdl.org> wrote:
> >
> > We do seem to have had a few reports of ppp regressions around this
> > timeframe.
> 
> me too.  I couldn't use 2.6.16 at home on my pppoe connected router
> because it was so slow.  I didn't have time to debug.  I can probably
> try patches and provide more data too.  Tell me what is needed.

probably git-bisect, sorry.  It's the sort of thing you can do while
reading a good book ;)

> Is there a bugzilla on this?

I don't think so.  Bubgzilla records which I'm folowing which mention ppp
are:

http://bugzilla.kernel.org/show_bug.cgi?id=5695
http://bugzilla.kernel.org/show_bug.cgi?id=6197
http://bugzilla.kernel.org/show_bug.cgi?id=6402

Perhaps the final one is related.
