From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: BUG? locking issue(networking?) with latest git
Date: Thu, 4 Sep 2008 07:21:56 +0000
Message-ID: <20080904072155.GA4691@ff.dom.local>
References: <200809031422.24883.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:17333 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbYIDHWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 03:22:04 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2475682fkq.5
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2008 00:22:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200809031422.24883.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-09-2008 13:22, Denys Fedoryshchenko wrote:
> I am getting strange lockup, all operations (tc, ifconfig,pppd) after few days running pppoe-server.
> 
> Programgs getting blocked very strange way, i am not able to kill them even.
> Softlockup detection enabled, lock dependencies (except lock dependency engine debugging), 
> RT mutexes and deadlock detection enabled too.
> 
> I notice this bug few weeks ago, even before latest patches, and seems it still remains.
> 

Do you mean this didn't happen with some 2.6.27-rc's? (There was quite
substantial change in ppp_generic with lock_kernel() in 2.6.27-rc1.)

> 
> Here is result of SysRQ +T:
> 

Alas it shows only some tasks waiting for locks. Maybe it's enough for
someone with better ppp knowledge, but unless there is such a response
I guess you should better try with PROVE_LOCKING turned on yet.

Jarek P.
