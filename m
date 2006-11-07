From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Tue, 07 Nov 2006 14:22:00 -0800 (PST)
Message-ID: <20061107.142200.115911407.davem@davemloft.net>
References: <1162924354.10806.172.camel@localhost.localdomain>
	<20061107.124557.21592397.davem@davemloft.net>
	<4550FFA9.8040503@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tim.c.chen@linux.intel.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50839
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1753765AbWKGWWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 17:22:00 -0500
To: jheffner@psc.edu
In-Reply-To: <4550FFA9.8040503@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 07 Nov 2006 16:50:33 -0500

> The only stack I know of that does this currently is linux, and in doing 
> so does not conform to the spec. ;)  Sending to a BSD receiver will 
> result in the same behavior, so the "right place" to fix this is on the 
> sending side.  (I know the issue of packet vs. byte counting has come up 
> many times over the last 10 years or so, and many arguments have been 
> made on either side... I don't mean this to be flame bait but it's clear 
> what will happen in this scenario.)

John, you cannot change the N-million existing Linux systems
out there doing congestion control via byte counting.  You
cannot do this no matter how much you wish it so :-)
