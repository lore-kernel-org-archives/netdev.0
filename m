From: David Miller <davem@davemloft.net>
Subject: Re: SACK scoreboard
Date: Tue, 08 Jan 2008 22:41:44 -0800 (PST)
Message-ID: <20080108.224144.234253941.davem@davemloft.net>
References: <20080108.144456.173014334.davem@davemloft.net>
	<p73sl17pwfy.fsf@bingen.suse.de>
	<47844D1C.1060706@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, ilpo.jarvinen@helsinki.fi,
	lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55794
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751306AbYAIGlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:41:45 -0500
In-Reply-To: <47844D1C.1060706@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Heffner <jheffner@psc.edu>
Date: Tue, 08 Jan 2008 23:27:08 -0500

> I also wonder how much of a problem this is (for now, with window sizes 
> of order 10000 packets.  My understanding is that the biggest problems 
> arise from O(N^2) time for recovery because every ack was expensive. 
> Have current tests shown the final ack to be a major source of problems?

Yes, several people have reported this.

It's a real issue, and it's only going to get worse.
