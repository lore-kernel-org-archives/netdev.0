From: Rick Jones <rick.jones2@hp.com>
Subject: Re: why does tcp_v[46]_conn_request not inc MIB stats
Date: Tue, 18 Sep 2007 10:14:57 -0700
Message-ID: <46F00791.2030909@hp.com>
References: <46E5900A.3010009@hp.com>	<1189461284.11066.10.camel@w-sridhar2.beaverton.ibm.com>	<20070914.201152.35026256.davem@davemloft.net> <p73wsuow7t0.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, sri@us.ibm.com,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:51013 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755716AbXIRRPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 13:15:50 -0400
In-Reply-To: <p73wsuow7t0.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> David Miller <davem@davemloft.net> writes:
> 
> 
>>This is limiting embryonic mini-socket creation.  The listen overflow
>>should only increment when the 3-way handshake completion is aborted
>>because the listening socket limit is exceeded, which is entirely
>>different from the embryonic limit.
> 
> 
> That's true, but I think Rick has a point in that there should 
> be some sort of (different) counter counting this.  In general
> I believe every point in the stack who drops a packet should
> have a statistics counter so that it can be later diagnosed.
> 
> Rick, the best way to get such a counter in is to just send a patch,
> don't ask for it.

I will try to work something up after cleaning-up the other listenq 
patch to remove the /proc/net/tcp[6] stuff, and an iproute2 patch I have 
to allow setting rto_min, rtt and rttvar using tc-esque units.

rick jones
