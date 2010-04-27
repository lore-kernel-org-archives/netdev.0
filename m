From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 10:06:02 -0700 (PDT)
Message-ID: <20100427.100602.52191517.davem@davemloft.net>
References: <4BD6E887.3000804@athenacr.com>
	<20100427.095108.68126984.davem@davemloft.net>
	<4BD71890.2050606@athenacr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: bmb@athenacr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46631
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752293Ab0D0RF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 13:05:56 -0400
In-Reply-To: <4BD71890.2050606@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Bloniarz <bmb@athenacr.com>
Date: Tue, 27 Apr 2010 13:02:08 -0400

> Maybe I'm misunderstanding... won't it distribute the
> packet handling load to multiple cores, but then all
> those cores will contend trying to deliver those packets
> to the single socket?
> 
> I was assuming that this'd be a net loss over just doing
> all the protocol handling on a single core. I haven't
> done any benchmarks yet.

Whether it's a new loss depends upon the application.

Also, on the non-application side f.e. a router or firewall, this is
exactly the behavior you want.
