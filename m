From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 0/3] Proposal for VRF-lite
Date: Mon, 08 Jun 2015 22:41:15 +0200
Message-ID: <1433796075.1992197.290139129.5F4BF968@webmail.messagingengine.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
 <5575E964.7060308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com,
	andy gospodarek <gospo@cumulusnetworks.com>,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: David Ahern <dsahern@gmail.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>, davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41734 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752533AbbFHUlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 16:41:16 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id DD9582141B
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2015 16:41:15 -0400 (EDT)
In-Reply-To: <5575E964.7060308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 8, 2015, at 21:13, David Ahern wrote:
> On 6/8/15 12:35 PM, Shrijeet Mukherjee wrote:
> > 5. Debugging is built-in as tcpdump and counters on the VRF device
> >     works as is.
> 
> Is the intent that something like this
> 
>    tcpdump -i vrf0
> 
> can be used to see vrf traffic?
> 
> vrf_handle_frame only bumps counters; it does not switch skb->dev to the 
> vrf device so for Rx path tcpdump will not get the packets. ie., tcpdump 
> only shows outbound packets.

My hope initially was that the vrf interface type would be as slim as
possible. I
am not even sure if we need packet counters, as one could easily have
user
space handle that by looking up the relations and accumulating them.
Same
for VRF traffic.

But the current model does allow to add support for that easily, so why
not? It
depends on how far we can and want to move parts of the logic into the
core
stack in the end.

Would you see this as a requirement?

Thanks,
Hannes
