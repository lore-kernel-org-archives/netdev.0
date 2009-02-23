From: David Miller <davem@davemloft.net>
Subject: Re: Why linux keeps connected routes when link goes down
Date: Mon, 23 Feb 2009 15:33:53 -0800 (PST)
Message-ID: <20090223.153353.237733933.davem@davemloft.net>
References: <20090220171912.GA7315@csclub.uwaterloo.ca>
	<20090220.121508.252047266.davem@davemloft.net>
	<20090223143830.GA23244@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: homecreate@list.ru, netdev@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751023AbZBWXeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 18:34:13 -0500
In-Reply-To: <20090223143830.GA23244@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Date: Mon, 23 Feb 2009 09:38:30 -0500

> On Fri, Feb 20, 2009 at 12:15:08PM -0800, David Miller wrote:
> > The route is tied to the IP address, and the route is therefore
> > created and destroyed alongside the IP address.
> 
> That's how it works now.  It wasn't how it worked in linux a long
> time ago.  Long ago you had to create the route yourself in userspace
> (which was actually to some extent better than the current setup).
> The current method is simpler to understand for your typical user though.

I don't remember Linux ever not creating a subnet route when an IP
address was added to an interface.  And I also don't remember Linux
ever deleting an IP address on interface down.

Maybe it happened back in 0.99pl5 times, but we're talking at least
10 years ago.
