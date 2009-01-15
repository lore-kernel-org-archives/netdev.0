From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 11:57:13 +0200
Message-ID: <200901151157.13340.denys@visp.net.lb>
References: <20081010090426.GA6054@ff.dom.local> <496F04AB.2080705@bigtelecom.ru> <20090115095454.GA5461@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Chris Caputo <ccaputo@alt.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:50819 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbZAOJ5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 04:57:25 -0500
In-Reply-To: <20090115095454.GA5461@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I didn't notice a bug, just because all that time i was using it without 
hrtimers (because of nmi_watchdog).

On Thursday 15 January 2009 11:54:54 Jarek Poplawski wrote:
> On Thu, Jan 15, 2009 at 12:40:59PM +0300, Badalian Vyacheslav wrote:
> ...
>
> > Jarek, i easy can test patch 4 without 2+3 if it needed at heavy
> > production server. I use dynamic routing and if server crashed - traffic
> > go to another pc after few seconds. I not test it because you say that
> > its not needed if for me help 3+2. I apply it today and test at few
> > servers.
>
> Yes, I thought it's so rare we can wait till 2.6.29, while you had this
> patched, and Denys seemed to not see it after changing his sever. But
> I have changed my mind after seeing Chris's report...
>
> I'm not sure if Peter would recomend something better yet, so I guess
> you could wait with this testing for his opinion.
>
> Thanks,
> Jarek P.


