From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: BUG? locking issue(networking?) with latest git
Date: Thu, 4 Sep 2008 12:03:07 +0300
Message-ID: <200809041203.07460.denys@visp.net.lb>
References: <20080904072155.GA4691@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:45389 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbYIDJE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 05:04:26 -0400
In-Reply-To: <20080904072155.GA4691@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 September 2008, Jarek Poplawski wrote:
> On 03-09-2008 13:22, Denys Fedoryshchenko wrote:
> > I am getting strange lockup, all operations (tc, ifconfig,pppd) after few
> > days running pppoe-server.
> >
> > Programgs getting blocked very strange way, i am not able to kill them
> > even. Softlockup detection enabled, lock dependencies (except lock
> > dependency engine debugging), RT mutexes and deadlock detection enabled
> > too.
> >
> > I notice this bug few weeks ago, even before latest patches, and seems it
> > still remains.
>
> Do you mean this didn't happen with some 2.6.27-rc's? (There was quite
> substantial change in ppp_generic with lock_kernel() in 2.6.27-rc1.)
I was not able to run early rc's on my pppoe's. Do you suggest to try reverse 
those changes?

> Alas it shows only some tasks waiting for locks. Maybe it's enough for
> someone with better ppp knowledge, but unless there is such a response
> I guess you should better try with PROVE_LOCKING turned on yet.
It is already turned on.
>
> Jarek P.


