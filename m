From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: BUG? locking issue(networking?) with latest git
Date: Thu, 4 Sep 2008 09:38:54 +0000
Message-ID: <20080904093854.GA5407@ff.dom.local>
References: <20080904072155.GA4691@ff.dom.local> <200809041203.07460.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:54049 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754147AbYIDJjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 05:39:02 -0400
Received: by wr-out-0506.google.com with SMTP id 69so2756083wri.5
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2008 02:39:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200809041203.07460.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 04, 2008 at 12:03:07PM +0300, Denys Fedoryshchenko wrote:
> On Thursday 04 September 2008, Jarek Poplawski wrote:
> > On 03-09-2008 13:22, Denys Fedoryshchenko wrote:
> > > I am getting strange lockup, all operations (tc, ifconfig,pppd) after few
> > > days running pppoe-server.
> > >
> > > Programgs getting blocked very strange way, i am not able to kill them
> > > even. Softlockup detection enabled, lock dependencies (except lock
> > > dependency engine debugging), RT mutexes and deadlock detection enabled
> > > too.
> > >
> > > I notice this bug few weeks ago, even before latest patches, and seems it
> > > still remains.
> >
> > Do you mean this didn't happen with some 2.6.27-rc's? (There was quite
> > substantial change in ppp_generic with lock_kernel() in 2.6.27-rc1.)
> I was not able to run early rc's on my pppoe's. Do you suggest to try reverse 
> those changes?

No, I don't think reverting them would be easy enough (except moving
back to 2.6.26). I simply wonder if you think there were some
2.6.27-rc's tried by you, which didn't lockup like this.

> > Alas it shows only some tasks waiting for locks. Maybe it's enough for
> > someone with better ppp knowledge, but unless there is such a response
> > I guess you should better try with PROVE_LOCKING turned on yet.
> It is already turned on.

So I misread this "except lock dependency engine debugging" part. OK,
I'll try to think about it, but any additional logs should be helpful.
BTW, I wonder if it's possible to test this without SMP?

Jarek P.
