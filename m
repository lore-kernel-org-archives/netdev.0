From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] ovs: limit ovs recursions in
 ovs_execute_actions to not corrupt stack
Date: Mon, 18 Jan 2016 11:50:30 -0500 (EST)
Message-ID: <20160118.115030.221096335100780663.davem@davemloft.net>
References: <CAOrHB_BCZRG8NinFintTcaRd0MBsYPt-hAH9LG+6uNwOa0GQaA@mail.gmail.com>
	<20160117.192628.1780434341967114696.davem@davemloft.net>
	<569CCAAC.6060906@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org,
	simon.horman@netronome.com, eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755742AbcARQue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 11:50:34 -0500
In-Reply-To: <569CCAAC.6060906@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 18 Jan 2016 12:21:16 +0100

> I don't think that -rt kernels are important for openvswitch right
> now, so this is just a safe guard.

Hannes, whilst I don't want to explicitly make things harder for the -rt
folks, I don't think it's appropriate to put unnecessary preemtption
disables into the main kernel like this.

Someone reading the code as-is will say this is superfluous and (correctly)
submit a patch to remove the preemption disables.

Please remove this from your patch, someone can deal with this in the
-rt kernel as needed.
