From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Mon, 24 Jul 2006 17:45:18 -0700 (PDT)
Message-ID: <20060724.174518.52116903.davem@davemloft.net>
References: <20060724.162250.55836503.davem@davemloft.net>
	<200607250202.02913.ak@suse.de>
	<44C565D1.6070202@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, rdreier@cisco.com, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13464
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932365AbWGYApI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 20:45:08 -0400
To: rick.jones2@hp.com
In-Reply-To: <44C565D1.6070202@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 24 Jul 2006 17:29:05 -0700

> Nirvana I suppose would be the addition of a field in the header
> which could be used for the determination of where to process. A
> Transport Protocol option I suppose, maybe the IPv6 flow id, but
> knuth only knows if anyone would go for something along those lines.
> It does though mean that the "state" is per-packet without it having
> to be based on addressing information.  Almost like RDMA arriving
> saying where the data goes, but this thing says where the processing
> should happen :)

Since the full interpretation of the TCP timestamp option field value
is largely local to the peer setting it, there is nothing wrong with
stealing a few bits for destination cpu information.

It would have to be done in such a way as to not make the PAWS
tests fail by accident.  But I think it's doable.
