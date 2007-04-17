From: David Miller <davem@davemloft.net>
Subject: Re: TCP connection stops after high load.
Date: Tue, 17 Apr 2007 12:51:59 -0700 (PDT)
Message-ID: <20070417.125159.43010586.davem@davemloft.net>
References: <7e63f56c0704170058m35d44a8ajfe5d97c4c7a8d87a@mail.gmail.com>
	<20070417.123941.119226635.davem@davemloft.net>
	<4625246E.2090700@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: coroberti@gmail.com, netdev@vger.kernel.org,
	greearb@candelatech.com, moser.michael@gmail.com
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57563
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161029AbXDQTv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 15:51:57 -0400
In-Reply-To: <4625246E.2090700@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 17 Apr 2007 15:47:58 -0400

> My only reservation in submitting this to -stable is that it will in 
> many cases increase the default tcp_mem values, which in turn can 
> increase the default tcp_rmem values, and therefore the window scale. 
> There will be some set of people with broken firewalls who trigger that 
> problem for the first time by upgrading along the stable branch.  While 
> it's not our fault, it could cause some complaints...

It is a very valid concern.

However this is fixing a problem where we are in the wrong,
whereas the firewall issues are external and should not
block us from being able to fix our own bugs :-)
