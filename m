From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: SACK scoreboard
Date: Wed, 9 Jan 2008 14:55:30 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801091435390.31652@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712111547300.18529@kivilampi-30.cs.helsinki.fi>
 <20080107.233617.203640686.davem@davemloft.net> <4783AA29.3080406@psc.edu>
 <20080108.144456.173014334.davem@davemloft.net> <p73sl17pwfy.fsf@bingen.suse.de>
 <47844D1C.1060706@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, lachlan.andrew@gmail.com,
	Netdev <netdev@vger.kernel.org>, quetchen@caltech.edu
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35773 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbYAIMze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 07:55:34 -0500
In-Reply-To: <47844D1C.1060706@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Jan 2008, John Heffner wrote:

> Andi Kleen wrote:
> > David Miller <davem@davemloft.net> writes:
> > > The big problem is that recovery from even a single packet loss in a
> > > window makes us run kfree_skb() for a all the packets in a full
> > > window's worth of data when recovery completes.
> > 
> > Why exactly is it a problem to free them all at once? Are you worried
> > about kernel preemption latencies?
> 
> I also wonder how much of a problem this is (for now, with window sizes of
> order 10000 packets.  My understanding is that the biggest problems arise from
> O(N^2) time for recovery because every ack was expensive. Have current 
> tests shown the final ack to be a major source of problems?

This thread got started because I tried to solve the other latencies but 
realized that it helps very little because this latency spike would 
have remained unsolved and it happens in one of the most common case.

-- 
 i.
