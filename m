From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [Patch net-next] tcp: add a global sysctl to control TCP delayed
 ack
Date: Sat, 6 Apr 2013 17:38:26 +0200
Message-ID: <20130406153826.GC3589@virgo.local>
References: <1365070560-11544-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44390 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423178Ab3DFPiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 11:38:46 -0400
Content-Disposition: inline
In-Reply-To: <1365070560-11544-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Cong Wang | 2013-04-04 18:16:00 [+0800]:

>According to previous discussion, it seems there is no
>reasonable heuristics.
>
>Similar to TCP_QUICK_ACK option, but for people who can't
>modify the source code and still wants to control
>TCP delayed ACK behavior.
>
>David, do you still have any objection?

Maybe:

http://kerneltrap.org/mailarchive/linux-netdev/2010/8/23/6283640

I submitted a identical patch 3 years back. The consensus was to implement
this on a per-route tunable - not on a global sysctl tunable. OK, consensus
is not the correct wording ... ;-)

Hagen
