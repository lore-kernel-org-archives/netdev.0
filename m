From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [RFT 0/4] fib_trie cleanup patches
Date: Wed, 8 Aug 2007 18:07:13 +0200
Message-ID: <18105.59953.961468.899750@robur.slu.se>
References: <20070727075917.470055328@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:40558 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752573AbXHHQMV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 12:12:21 -0400
In-Reply-To: <20070727075917.470055328@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Stephen Hemminger writes:

 > I don't have a machine with anywhere near enough routes to test this,
 > so would someone with many routes give it a go and make sure nothing
 > got busted in the process.

 Hello! 

 It's not only the numbers of routes thats important... 

 Anyway I've done what can to verify that route selection (comparing
 lookups via netlink and userland longest-prefix-match using the same
 full routing table) and locking (concurrent rDoS on multiple CPU:s 
 also while loading the full routing table) is intact.

 Keep TKEY_GET_MASK in patch #2 as it gives some hint whats going on.

 And how about Paul E. McKenney comment about rcu_dereference() 
 covering the initial fetch?

 BTW. Right now the lab is setup for tests described above...

 Cheers.

					--ro

 
