From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: BUG? locking issue(networking?) with latest git
Date: Thu, 4 Sep 2008 10:02:07 +0000
Message-ID: <20080904100206.GB5407@ff.dom.local>
References: <20080904072155.GA4691@ff.dom.local> <200809041203.07460.denys@visp.net.lb> <20080904093854.GA5407@ff.dom.local> <200809041246.11255.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:54285 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316AbYIDKCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 06:02:14 -0400
Received: by wr-out-0506.google.com with SMTP id 69so2761612wri.5
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2008 03:02:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200809041246.11255.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 04, 2008 at 12:46:11PM +0300, Denys Fedoryshchenko wrote:
...
> I tried to check for any additional logs, but there is nothing seems.
> Once i got softlockup for pppd, and server restarted. Other times it is just 
> getting stuck on any network operations (ifconfig, pppd crashing in the 
> middle, tc). I am not able to attach to processes by strace/gdb, so it is 
> difficult to tell even on which point it does crash.

BTW, I guess, it was checked with 2.6.26 (or .25) with the same config,
scripts and similar load and we are sure it's a really new bug?

Jarek P.
