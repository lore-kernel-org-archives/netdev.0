From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Sun, 05 Feb 2012 16:48:12 -0500 (EST)
Message-ID: <20120205.164812.383526470219039003.davem@davemloft.net>
References: <20120205125325.GA31578@elastic.org>
	<20120205191708.GA5337@neilslaptop.think-freely.org>
	<20120205200428.GB2816@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, fche@elastic.org, satoru.moriya@hds.com,
	netdev@vger.kernel.org, tgraf@infradead.org,
	stephen.hemminger@vyatta.com, eric.dumazet@gmail.com,
	seiji.aguchi@hds.com, fche@sourceware.org,
	mathieu.desnoyers@polymtl.ca, rostedt@goodmis.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab2BEVwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 16:52:16 -0500
In-Reply-To: <20120205200428.GB2816@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Let me put an end to this dicussion right now, I'm not applying
any patches which just add tracepoints into the TCP stack.

That's not the solution, and you can hoot and hollar all you want
about it, I simply do not care.

The solution is a way to manage socket events, and be able to choose
which sockets emit those events, in a useful way, via the perf event
infrastructure.

This means we need a perf event socket layer that allows filtering on
socket flow ID, which enables per-socket event and statistics
gathering, and so forth.
