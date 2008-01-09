From: John Heffner <jheffner@psc.edu>
Subject: Re: SACK scoreboard
Date: Tue, 08 Jan 2008 23:27:08 -0500
Message-ID: <47844D1C.1060706@psc.edu>
References: <Pine.LNX.4.64.0712111547300.18529@kivilampi-30.cs.helsinki.fi>	<20080107.233617.203640686.davem@davemloft.net>	<4783AA29.3080406@psc.edu>	<20080108.144456.173014334.davem@davemloft.net> <p73sl17pwfy.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:60876 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751910AbYAIE1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 23:27:47 -0500
In-Reply-To: <p73sl17pwfy.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> David Miller <davem@davemloft.net> writes:
>> The big problem is that recovery from even a single packet loss in a
>> window makes us run kfree_skb() for a all the packets in a full
>> window's worth of data when recovery completes.
> 
> Why exactly is it a problem to free them all at once? Are you worried
> about kernel preemption latencies?
> 
> -Andi


I also wonder how much of a problem this is (for now, with window sizes 
of order 10000 packets.  My understanding is that the biggest problems 
arise from O(N^2) time for recovery because every ack was expensive. 
Have current tests shown the final ack to be a major source of problems?

   -John
