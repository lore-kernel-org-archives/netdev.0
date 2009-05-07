From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [patch next 4/4] netxen: disable rss for GbE ports
Date: Wed, 6 May 2009 17:31:57 -0700
Message-ID: <4A022BFD.40806@netxen.com>
References: <4A0217F6.7060005@netxen.com>	<20090506.163142.112368323.davem@davemloft.net>	<4A022666.4060906@netxen.com> <20090506.172801.102105067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:15072 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753795AbZEGAb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 20:31:57 -0400
In-Reply-To: <20090506.172801.102105067.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
>> I do see a reason for conserving msix vectors, unless
>> they are bringing performance gain.
> 
> Then scale the number of RX queues in use by port speed.

Yes, I was proposing one rx queue per port, which is implied
by disabling rss. May be two ...


-Dhananjay
