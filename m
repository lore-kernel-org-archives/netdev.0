From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 1/3] ctnetlink: allocate right-sized ctnetlink skb
Date: Wed, 25 Mar 2009 21:51:50 +0100
Message-ID: <49CA9966.9010205@trash.net>
References: <20090325203404.581023828@jonathan.eitzenberger.org> <20090325204600.456638455@jonathan.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Holger Eitzenberger <holger@eitzenberger.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39719 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbZCYUv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 16:51:59 -0400
In-Reply-To: <20090325204600.456638455@jonathan.eitzenberger.org>
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

Applied, thanks.
