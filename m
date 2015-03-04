From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] Basic MPLS support take 2
Date: Wed, 04 Mar 2015 00:27:34 -0500 (EST)
Message-ID: <20150304.002734.1453464446418392919.davem@davemloft.net>
References: <20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<87vbihtvts.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, santiago@crfreenet.org,
	horms@verge.net.au
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753802AbbCDF1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 00:27:36 -0500
In-Reply-To: <87vbihtvts.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 03 Mar 2015 19:06:39 -0600

> On top of my two pending neighbour table prep patches here is the mpls
> support refactored to use them, and edited to not drop routes when
> an interface goes down.  Additionally the addition of RTA_LLGATEWAY
> has been replaced with the addtion of RTA_VIA.  RTA_VIA being an
> attribute that includes the address family as well as the address
> of the next hop.
> 
> MPLS is at it's heart simple and I have endeavoured to maintain that
> simplicity in my implemenation.
> 
> This is an implementation of a RFC3032 forwarding engine, and basic MPLS
> egress logic.  Which should make linux sufficient to be a mpls
> forwarding node or to be a LSA (Label Switched Router) as it says in all
> of the MPLS documents.  The ingress support will follow but it deserves
> it's own discussion so I am pushing it separately.

Ok, with the neigh changes, I think I'm fine with this.

Series applied, thanks.

Please think very carefully about the netlink API you've created to
config this stuff, once we hit the next merge window we will be stuck
with this thing forever.

Thanks.
