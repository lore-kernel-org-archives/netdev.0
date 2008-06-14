From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Sat, 14 Jun 2008 08:27:58 +0200
Message-ID: <20080614062758.GA23803@elte.hu>
References: <20080612.211959.52937006.davem@davemloft.net> <20080614060320.GA18454@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:32932 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459AbYFNG2M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2008 02:28:12 -0400
Content-Disposition: inline
In-Reply-To: <20080614060320.GA18454@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> FYI, that regression is not fully fixed yet - your revert differs from 
> the one i tested (from Ilpo) by the delta patch below. Without the 
> extra change below i got this net/sched/sch_generic.c warning, twice:
> 
> [  173.354049] NETDEV WATCHDOG: eth0: transmit timed out
> [  173.354148] ------------[ cut here ]------------
> [  173.354221] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0x9a/0xec()

just to clarify the bug pattern: the box was still accessible after the 
warning. So this is a far less serious problem and i'd suggest we open 
up a separate regression entry for it and consider the hung-TCP problem 
closed. (i havent seen the hang in the last week, with either version of 
the tcp-accept reverts)

	Ingo
