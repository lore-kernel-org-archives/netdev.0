From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
	negotiation
Date: Thu, 18 Dec 2008 06:56:17 +0100
Message-ID: <20081218055617.GC6298@gerrit.erg.abdn.ac.uk>
References: <20081208.011917.176472177.davem@davemloft.net> <1229175685-18716-1-git-send-email-gerrit@erg.abdn.ac.uk> <1229175685-18716-2-git-send-email-gerrit@erg.abdn.ac.uk> <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk> <e2d7436a0812130555r52422bel1dd9b66ba8479e2a@mail.gmail.com> <20081213145655.GA14240@gerrit.erg.abdn.ac.uk> <e2d7436a0812140650r41b601dfgc3bbf41f01c2bb5d@mail.gmail.com> <20081216055540.GC6199@gerrit.erg.abdn.ac.uk> <e2d7436a0812160331h63152b26kd4aad6b449ed7f8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Micha? Miros?aw <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:64283 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751378AbYLRF4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 00:56:25 -0500
Content-Disposition: inline
In-Reply-To: <e2d7436a0812160331h63152b26kd4aad6b449ed7f8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > Hence your suggestion does not improve the code. I maintain that it is
| > correct. And it has proven to work in the test tree for more than one
| > year, including tests with up to 100 parallel (iperf) connections.
| 
| The read-lock is just a memory barrier here (not a read memory barrier
| as I wrote
| before) and it's not needed here. If I read the code correctly you are
| testing a single
| pointer to be NULL and don't really care about ordering wrt module
| initialization.
| 
| You can actually annotate ccids[] as read_mostly (it's changed only on module
| load/unload) and protect it with RCU instead of the home-grown rwlock
| you are using.
| 
Hm the details are not so important here. What is important is that your
observation and questioning whether the code makes sense has lead to 
finding a deeper problem. Without your posting that may not have
happened. So many thanks indeed, if you have any more observations,
please keep them coming.
