From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Why linux keeps connected routes when link goes down
Date: Fri, 20 Feb 2009 12:19:12 -0500
Message-ID: <20090220171912.GA7315@csclub.uwaterloo.ca>
References: <200902190203.41497.homecreate@list.ru> <20090218.155207.139931991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: homecreate@list.ru, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:48334 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753687AbZBTRTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 12:19:13 -0500
Content-Disposition: inline
In-Reply-To: <20090218.155207.139931991.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 18, 2009 at 03:52:07PM -0800, David Miller wrote:
> Because the IP addresses are still assigned to the interface.
> 
> IP addresses are owned by the "host" rather than specific interfaces
> under Linux.  So just bringing an interface down does not disable
> IP addresses configured to that interface.
> 
> If you want all the routes to go away, explicitly delete the IP
> addresses.

An interface IP address and the router to the connected subnet are not
the same thing.  Keep the IP address but drop the route to the subnet
you can no longer reach.

By elliminating the route to stuff you can no longer reach, quagga can
do its job to provide an alternative way to reach the subnet.  It can
not do so as long as the kernel insist on providing a now useless route.

-- 
Len Sorensen
