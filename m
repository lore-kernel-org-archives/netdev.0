From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] Multiple IPV6 Routing Tables & Policy Routing
Date: Thu, 27 Jul 2006 00:11:00 +0200
Message-ID: <20060726221100.325687073@postel.suug.ch>
Cc: vnuorval@tcs.hut.fi, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:17846 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751233AbWGZWT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 18:19:56 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Thought it might be time to go through a round of comments
on this work. Even though I've almost rewritten all the code
the patches are based on the work found on www.mobile-ipv6.org.
I have no idea which code was written by whom so just email me
to get the credits right.

Main differences to the version found on mobile-ipv6.org is
that I removed table refcnt and defined that tables cannot
disappear once created to simplify things and avoid too many
atomic operations when looking up routes. I've replaced the
table array with a hash table to prepare it for > 255 tables
and made things aware of the new default router selection
code and experimental route info stuff added recently.

It's not final but somewhat working, I'm eager to see comments
or patches. I apologize if I've tramped onto anybody's foot
by taking this up and submitting it, this isn't meant as an
attempt to steal credits but rather to pick up good code and
finally get it upstream after a very long while.

