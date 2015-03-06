From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] DECnet: Only use neigh_ops for adding the
 link layer header
Date: Fri, 06 Mar 2015 14:55:46 -0500 (EST)
Message-ID: <20150306.145546.1899132351665683227.davem@davemloft.net>
References: <87twy0n3f8.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756462AbbCFTzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 14:55:49 -0500
In-Reply-To: <87twy0n3f8.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 04 Mar 2015 10:16:43 -0600

> 
> Other users users of the neighbour table use neigh->output as the method
> to decided when and which link-layer header to place on a packet.
> DECnet has been using neigh->output to decide which DECnet headers to
> place on a packet depending which neighbour the packet is destined for.
> 
> The DECnet usage isn't totally wrong but it can run into problems if the
> neighbour output function is run for a second time as the teql driver
> and the bridge netfilter code can do.
> 
> Therefore to avoid pathologic problems later down the line and make the
> neighbour code easier to understand by refactoring the decnet output
> code to only use a neighbour method to add a link layer header to a
> packet.
> 
> This is done by moving the neigbhour operations lookup from
> dn_to_neigh_output to dn_neigh_output_packet.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied, thanks Eric.
