From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 4/6] ctnetlink: allocate right-sized ctnetlink skb
Date: Wed, 25 Mar 2009 18:46:39 +0100
Message-ID: <49CA6DFF.7050103@trash.net>
References: <20090316220659.756862181@jonathan.eitzenberger.org> <20090316221139.605528511@jonathan.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Holger Eitzenberger <holger@eitzenberger.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35799 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760483AbZCYRqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 13:46:47 -0400
In-Reply-To: <20090316221139.605528511@jonathan.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Holger Eitzenberger wrote:
> Try to allocate a Netlink skb roughly the size of the actual
> message, with the help from the l3 and l4 protocol helpers.
> This is all to prevent a reallocation in netlink_trim() later.
> 
> The overhead of allocating the right-sized skb is rather small, with
> ctnetlink_alloc_skb() actually being inlined away on my x86_64 box.
> The size of the per-proto space is determined at registration time of
> the protocol helper.

This one clashes with Florian's changes to get rid of
nf_ct_l4proto_find_get(). I've pushed out the patches I've
already applied, please rediff the remaining ones against
my current tree. Thanks.
