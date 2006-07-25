From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RDMA will be reverted
Date: Mon, 24 Jul 2006 17:55:24 -0700
Message-ID: <44C56BFC.7080000@hp.com>
References: <20060724.162250.55836503.davem@davemloft.net>	<200607250202.02913.ak@suse.de> <44C565D1.6070202@hp.com> <20060724.174518.52116903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, rdreier@cisco.com, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:9411 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S932367AbWGYAz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 20:55:28 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060724.174518.52116903.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Mon, 24 Jul 2006 17:29:05 -0700
> 
> 
>>Nirvana I suppose would be the addition of a field in the header
>>which could be used for the determination of where to process. A
>>Transport Protocol option I suppose, maybe the IPv6 flow id, but
>>knuth only knows if anyone would go for something along those lines.
>>It does though mean that the "state" is per-packet without it having
>>to be based on addressing information.  Almost like RDMA arriving
>>saying where the data goes, but this thing says where the processing
>>should happen :)
> 
> 
> Since the full interpretation of the TCP timestamp option field value
> is largely local to the peer setting it, there is nothing wrong with
> stealing a few bits for destination cpu information.

Even enough bits for 1024 or 2048 CPUs in the single system image?  I have seen 
1024 touted by SGI, and with things going so multi-core, perhaps 16384 while 
sounding initially bizzare would be in the realm of theoretically possible 
before tooooo long.

> It would have to be done in such a way as to not make the PAWS
> tests fail by accident.  But I think it's doable.

That would cover TCP, are there similarly fungible fields in SCTP or other ULPs?

And if we were to want to get HW support for the thing, getting it adopted in a 
de jure standards body would probably be in order :)

rick jones
