From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tune back idle cwnd closing?
Date: Thu, 27 Apr 2006 13:19:21 -0700 (PDT)
Message-ID: <20060427.131921.79333703.davem@davemloft.net>
References: <444E31D9.1010705@psc.edu>
	<20060426.144540.39973302.davem@davemloft.net>
	<445103B5.2090603@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zach.brown@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35559
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030220AbWD0UTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 16:19:22 -0400
To: jheffner@psc.edu
In-Reply-To: <445103B5.2090603@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Thu, 27 Apr 2006 13:47:33 -0400

> (Most OS's don't do 2861, and it is not a standard.)

Are you so sure?  Doing cwnd timeout largely predates the congestion
window validation work, in fact by several years.

In RFC 2581, it mentions Van Jacobson's recommendation of this idle
period behavior, as just one example.

Your arguments about "all the feedback mechanisms are in place, so not
reducing the cwnd after idle doesn't hurt congestion control" could be
applied to the packet retransmit timeout handling of the congestion
window, and I think that's kind of silly.
