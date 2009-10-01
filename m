From: David Miller <davem@davemloft.net>
Subject: Re: Network hangs with 2.6.30.5
Date: Thu, 01 Oct 2009 15:49:13 -0700 (PDT)
Message-ID: <20091001.154913.88345178.davem@davemloft.net>
References: <pan.2009.09.03.19.55.37.672875@googlemail.com>
	<20090907072143.GA5966@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holger.hoffstaette@googlemail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, ilpo.jarvinen@helsinki.fi
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39715
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751646AbZJAWsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 18:48:54 -0400
In-Reply-To: <20090907072143.GA5966@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 7 Sep 2009 07:21:43 +0000

> While Eric is analyzing your data, I guess you could try reverting
> some stuff around this tcp_tw_recycle, and my tcp ignorance would
> point these commits for the beginning:
> 
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.30.y.git;a=commitdiff;h=fc1ad92dfc4e363a055053746552cdb445ba5c57
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.30.y.git;a=commitdiff;h=c887e6d2d9aee56ee7c9f2af4cec3a5efdcc4c72

Ilpo's cleanup (the second commit listed) looks most likely to
be a possibility.

But I surely cannot find any bugs in it, even after studying it
a few times.

Ilpo could you audit it one more time for us just in case?

I also looked through all the TCP commits in 2.6.29 to 2.6.30
and I could not find anything else that might cause stalls with
time-wait recycled connections.
