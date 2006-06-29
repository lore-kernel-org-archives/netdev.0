From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Thu, 29 Jun 2006 13:19:38 -0700 (PDT)
Message-ID: <20060629.131938.55726619.davem@davemloft.net>
References: <adawtazgawi.fsf@cisco.com>
	<20060629.124628.88476747.davem@davemloft.net>
	<1151611866.11739.57.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2528
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932408AbWF2UTk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 16:19:40 -0400
To: tom@opengridcomputing.com
In-Reply-To: <1151611866.11739.57.camel@trinity.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Tucker <tom@opengridcomputing.com>
Date: Thu, 29 Jun 2006 15:11:06 -0500

> Doesn't this position force vendors to build deeper adapters, not
> shallower adapters? Isn't this exactly the opposite of what is intended?

Nope.

Look at what the networking developers give a lot of attention and
effort to, things like TCP Large Receive Offload, and Van Jacobson net
channels, both of which are fully stack integrated receive performance
enhancements.  They do not bypass netfilter, they do not bypass
packet scheduling, and yet they provide a hardware assist performance
improvement for receive.

This has been stated over and over again.

If companies keep designing undesirable hardware that unnecessarily
takes features away from the user, that really is not our problem.
