From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 09:54:54 +0000
Message-ID: <20090115095454.GA5461@ff.dom.local>
References: <20081010090426.GA6054@ff.dom.local> <496EE1D4.6010709@bigtelecom.ru> <20090115080921.GC4190@ff.dom.local> <200901151101.15397.denys@visp.net.lb> <20090115090650.GF4190@ff.dom.local> <496F04AB.2080705@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Chris Caputo <ccaputo@alt.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:39734 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179AbZAOJzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 04:55:01 -0500
Content-Disposition: inline
In-Reply-To: <496F04AB.2080705@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 12:40:59PM +0300, Badalian Vyacheslav wrote:
...
> Jarek, i easy can test patch 4 without 2+3 if it needed at heavy
> production server. I use dynamic routing and if server crashed - traffic
> go to another pc after few seconds. I not test it because you say that
> its not needed if for me help 3+2. I apply it today and test at few servers.

Yes, I thought it's so rare we can wait till 2.6.29, while you had this
patched, and Denys seemed to not see it after changing his sever. But
I have changed my mind after seeing Chris's report...

I'm not sure if Peter would recomend something better yet, so I guess
you could wait with this testing for his opinion.

Thanks,
Jarek P.
