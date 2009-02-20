From: David Miller <davem@davemloft.net>
Subject: Re: Why linux keeps connected routes when link goes down
Date: Fri, 20 Feb 2009 12:15:08 -0800 (PST)
Message-ID: <20090220.121508.252047266.davem@davemloft.net>
References: <200902190203.41497.homecreate@list.ru>
	<20090218.155207.139931991.davem@davemloft.net>
	<20090220171912.GA7315@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: homecreate@list.ru, netdev@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57444
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751814AbZBTUP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 15:15:26 -0500
In-Reply-To: <20090220171912.GA7315@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Date: Fri, 20 Feb 2009 12:19:12 -0500

> By elliminating the route to stuff you can no longer reach, quagga can
> do its job to provide an alternative way to reach the subnet.

This is not necessarily true.

The subnet might be reachable by one of the other interfaces.
Just the same as someone might be able to reach the down
interface's IP address via another one of our interfaces.

The route is tied to the IP address, and the route is therefore
created and destroyed alongside the IP address.

As long as the IP address is active and associated with the
system, so is the route.
