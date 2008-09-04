From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: BUG? locking issue(networking?) with latest git
Date: Thu, 4 Sep 2008 17:14:05 +0300
Message-ID: <200809041714.05578.denys@visp.net.lb>
References: <20080904072155.GA4691@ff.dom.local> <200809041246.11255.denys@visp.net.lb> <20080904100206.GB5407@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:36390 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbYIDOP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 10:15:27 -0400
In-Reply-To: <20080904100206.GB5407@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 September 2008, Jarek Poplawski wrote:
> On Thu, Sep 04, 2008 at 12:46:11PM +0300, Denys Fedoryshchenko wrote:
> ...
>
> > I tried to check for any additional logs, but there is nothing seems.
> > Once i got softlockup for pppd, and server restarted. Other times it is
> > just getting stuck on any network operations (ifconfig, pppd crashing in
> > the middle, tc). I am not able to attach to processes by strace/gdb, so
> > it is difficult to tell even on which point it does crash.
>
> BTW, I guess, it was checked with 2.6.26 (or .25) with the same config,
> scripts and similar load and we are sure it's a really new bug?
config, scripts and everything is completely same.
It seems with nosmp i am getting watchdog fired (no messages over neconsole). 
Probably one CPU becoming too busy in this case, and when it is single CPU - 
such issue becoming critical and results in hardware watchdog triggering.

>
> Jarek P.


