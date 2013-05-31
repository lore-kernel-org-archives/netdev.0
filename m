From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 02/12] tipc: Add "max_ports" configuration
 parameter
Date: Fri, 31 May 2013 02:26:28 -0700 (PDT)
Message-ID: <20130531.022628.1036824788160880030.davem@davemloft.net>
References: <20130531083455.GA7568@eerihug-hybrid.ki.sw.ericsson.se>
	<20130531.014028.420559536226155172.davem@davemloft.net>
	<20130531092302.GA8131@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, ying.xue@windriver.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082Ab3EaJ0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 05:26:34 -0400
In-Reply-To: <20130531092302.GA8131@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>
Date: Fri, 31 May 2013 11:23:02 +0200

> On Fri, May 31, 2013 at 01:40:28AM -0700, David Miller wrote:
>> We never shrink the hash tables once we've grown them.  That's a
>> reasonable way to behave.
> 
> Very well.
> Currently, the refs/portID's are built up of a random part, and an index
> part. The index is obtained by masking against the table size.
> If the table is allowed to grow, we must remove the random part from the 
> portID. Otherwise we would index out a nonexistant or wrong port
> from a received packet..
> 
> But removing the random part would be a violation of the protocol spec, and
> potentially break interop between other implementations (like link selection..)

We allocate ports randomly for IPV4/IPV6 sockets, you can just fine too.
