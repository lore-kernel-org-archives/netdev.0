From: Andi Kleen <andi@firstfloor.org>
Subject: Re: why does tcp_v[46]_conn_request not inc MIB stats
Date: 18 Sep 2007 13:07:39 +0200
Message-ID: <p73wsuow7t0.fsf@bingen.suse.de>
References: <46E5900A.3010009@hp.com>
	<1189461284.11066.10.camel@w-sridhar2.beaverton.ibm.com>
	<20070914.201152.35026256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sri@us.ibm.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50798 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755234AbXIRLHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 07:07:44 -0400
In-Reply-To: <20070914.201152.35026256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> This is limiting embryonic mini-socket creation.  The listen overflow
> should only increment when the 3-way handshake completion is aborted
> because the listening socket limit is exceeded, which is entirely
> different from the embryonic limit.

That's true, but I think Rick has a point in that there should 
be some sort of (different) counter counting this.  In general
I believe every point in the stack who drops a packet should
have a statistics counter so that it can be later diagnosed.

Rick, the best way to get such a counter in is to just send a patch,
don't ask for it.

-Andi
