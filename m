From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 3/3] rcv path changes for vrf traffic
Date: Tue, 09 Jun 2015 07:35:01 +0200
Message-ID: <1433828101.2140577.290462785.240A77DD@webmail.messagingengine.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
 <87eae7a7a03708bda5560a5ea43b0fcac705c80d.1433561681.git.shm@cumulusnetworks.com>
 <1433793517.4616.4.camel@stressinduktion.org>
 <55763B56.3000503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>, davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	andy gospodarek <gospo@cumulusnetworks.com>,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: David Ahern <dsahern@gmail.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:40883 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752812AbbFIFfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 01:35:03 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id CDBC820F84
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2015 01:35:01 -0400 (EDT)
In-Reply-To: <55763B56.3000503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jun 9, 2015, at 03:03, David Ahern wrote:
> On 6/8/15 1:58 PM, Hannes Frederic Sowa wrote:
> > For rx layer I want to also propose my try:
> >
> > [PATCH net-next RFC] net: ipv4: arp: strong end system model semantics by per-interface local table override
> >
> 
> I applied only the first 2 patches from Shrijeet and then tried to apply 
> your patch; it doesn't apply. Way too many failures. What branch should 
> it apply too?

The patch is currently stand-alone and should apply ontop of net-next
commit 6da8253bdd3945b81377e4908d6d395a9956f8af
Author: Florian Fainelli <f.fainelli@gmail.com>
Date:   Mon Jun 8 11:05:20 2015 -0700

net: phy: bcm7xxx: update workaround to fix 100BaseT corner cases

Shrijeet and me will consolidate that soon.

Bye,
Hannes
