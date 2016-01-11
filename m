From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net, sched: add clsact qdisc
Date: Sun, 10 Jan 2016 22:17:15 -0500 (EST)
Message-ID: <20160110.221715.75880343274635261.davem@davemloft.net>
References: <61198814638d88ce3555dbecf8ef875523b95743.1452197856.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757624AbcAKDRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 22:17:18 -0500
In-Reply-To: <61198814638d88ce3555dbecf8ef875523b95743.1452197856.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu,  7 Jan 2016 22:29:47 +0100

> This work adds a generalization of the ingress qdisc as a qdisc holding
> only classifiers. The clsact qdisc works on ingress, but also on egress.
> In both cases, it's execution happens without taking the qdisc lock, and
> the main difference for the egress part compared to prior version of [1]
> is that this can be applied with _any_ underlying real egress qdisc (also
> classless ones).

Looks nice and clean, applied, thanks Daniel.
