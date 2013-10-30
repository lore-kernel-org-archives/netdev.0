From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Tue, 29 Oct 2013 22:34:56 -0400 (EDT)
Message-ID: <20131029.223456.778268322772629087.davem@davemloft.net>
References: <20131030020543.GA1925@gondor.apana.org.au>
	<CAPshTCgykFMa=4rnQ3TKa2cfgWYj4TgByO2GbzLzq71Y_=oc=Q@mail.gmail.com>
	<20131030021905.GA2089@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, eric.dumazet@gmail.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	mwdalton@google.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52239 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839Ab3J3Ce5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 22:34:57 -0400
In-Reply-To: <20131030021905.GA2089@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 30 Oct 2013 10:19:06 +0800

> On Tue, Oct 29, 2013 at 07:13:50PM -0700, Jerry Chu wrote:
>> On Tue, Oct 29, 2013 at 7:05 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>>
>> > If we are indeed able to do that, I doubt we would even need
>> > the sysctl patch since the GRO performance should be vastly
>> > superior to the non-GRO case, even for a router/bridge.
>> 
>> Probably not the case for the simple forwarding case. See my
>> test result of some small (5-8%) CPU+throughput penalty from
>> GRO (over GRE tunnel) posted previously. But I can believe
>> the number may be very different if the forwarding path involves
>> more work (NAT, iptables filtering,...,etc) resulting in a higher per
>> pkt cost.
> 
> Your numbers are with Eric's current patch that just linearises
> the packet, what I'm saying is that you don't need to linearise
> these packets since the packet boundaries are still there, just
> hidden inside each frag_list.

Agreed.
