From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 11:29:56 -0700 (PDT)
Message-ID: <20081029.112956.43077212.davem@davemloft.net>
References: <20081029163739.GB6732@linux.vnet.ibm.com>
	<49089E2D.8030907@cosmosbay.com>
	<20081029181114.GC6732@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, minyard@acm.org, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl,
	johnpol@2ka.mipt.ru, christian@myri.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43433
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752975AbYJ2SaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:30:21 -0400
In-Reply-To: <20081029181114.GC6732@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Wed, 29 Oct 2008 11:11:14 -0700

> OK.  However, this reasoning assumes that a socket with a given
> udp_hashfn() value will appear on one and only one list.  There are no
> side lists for sockets in other states?  (listen, &c)

Nope, with UDP things are very simple, just one hash table.
