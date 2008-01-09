From: Andi Kleen <andi@firstfloor.org>
Subject: Re: SACK scoreboard
Date: Wed, 09 Jan 2008 03:25:05 +0100
Message-ID: <p73sl17pwfy.fsf@bingen.suse.de>
References: <Pine.LNX.4.64.0712111547300.18529@kivilampi-30.cs.helsinki.fi>
	<20080107.233617.203640686.davem@davemloft.net>
	<4783AA29.3080406@psc.edu>
	<20080108.144456.173014334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jheffner@psc.edu, ilpo.jarvinen@helsinki.fi,
	lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:45503 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751144AbYAICZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 21:25:07 -0500
In-Reply-To: <20080108.144456.173014334.davem@davemloft.net> (David Miller's message of "Tue\, 08 Jan 2008 14\:44\:56 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
>
> The big problem is that recovery from even a single packet loss in a
> window makes us run kfree_skb() for a all the packets in a full
> window's worth of data when recovery completes.

Why exactly is it a problem to free them all at once? Are you worried
about kernel preemption latencies?

-Andi
