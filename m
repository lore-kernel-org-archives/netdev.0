From: Andi Kleen <ak@suse.de>
Subject: Re: RDMA will be reverted
Date: Thu, 29 Jun 2006 23:25:22 +0200
Message-ID: <200606292325.22698.ak@suse.de>
References: <adawtazgawi.fsf@cisco.com> <1151611866.11739.57.camel@trinity.ogc.int> <20060629.131938.55726619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: tom@opengridcomputing.com, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:31701 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932641AbWF2VZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 17:25:42 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.131938.55726619.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> They do not bypass netfilter, they do not bypass
> packet scheduling, and yet they provide a hardware assist performance
> improvement for receive.

Not that I'm a TOE advocate, but as long as the adapter leaves SYN/SYN-ACK
to the stack and only turns on RDMA in ESTABLISHED it could at least
do nearly all of netfilter too (as established in the channel discussion) 

-Andi
