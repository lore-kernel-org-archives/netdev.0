From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v5] ovs: limit ovs recursions in
 ovs_execute_actions to not corrupt stack
Date: Mon, 18 Jan 2016 12:10:18 -0500 (EST)
Message-ID: <20160118.121018.2292058052018055331.davem@davemloft.net>
References: <1453136628-9816-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org,
	simon.horman@netronome.com, eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829AbcARRKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 12:10:20 -0500
In-Reply-To: <1453136628-9816-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 18 Jan 2016 18:03:48 +0100

> It was seen that defective configurations of openvswitch could overwrite
> the STACK_END_MAGIC and cause a hard crash of the kernel because of too
> many recursions within ovs.
> 
> This problem arises due to the high stack usage of openvswitch. The rest
> of the kernel is fine with the current limit of 10 (RECURSION_LIMIT).
> 
> We use the already existing recursion counter in ovs_execute_actions to
> implement an upper bound of 5 recursions.
> 
> Cc: Pravin Shelar <pshelar@ovn.org>
> Cc: Simon Horman <simon.horman@netronome.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Hannes.
