From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Sat, 24 Mar 2007 12:26:27 -0700 (PDT)
Message-ID: <20070324.122627.75197002.davem@davemloft.net>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com>
	<46052FC0.8080804@trash.net>
	<4605758F.90205@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47190
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753191AbXCXT0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 15:26:53 -0400
In-Reply-To: <4605758F.90205@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Sat, 24 Mar 2007 19:01:35 +0000

> > - list_for_each_entry_safe is only needed if you remove something
> >   while iterating, its no replacement for locking
> 
> I've gotten into a bad habit of always using list_for_each_entry_safe. 
> I'll fix these (with locking).

bash$ egrep udp_encap_rcv net/ipv4/udp.c
