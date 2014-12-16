From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Tue, 16 Dec 2014 17:45:24 -0500 (EST)
Message-ID: <20141216.174524.888376617592272638.davem@davemloft.net>
References: <1418659395.9773.13.camel@edumazet-glaptop2.roam.corp.google.com>
	<548F0F62.7080704@fb.com>
	<5490B4EF.1030803@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbacik@fb.com, eric.dumazet@gmail.com,
	alexei.starovoitov@gmail.com, chavey@google.com, ycheng@google.com,
	kafai@fb.com, netdev@vger.kernel.org, hannes@stressinduktion.org,
	rostedt@goodmis.org, brakmo@fb.com, Kernel-team@fb.com
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbaLPWp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 17:45:26 -0500
In-Reply-To: <5490B4EF.1030803@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Tue, 16 Dec 2014 17:40:47 -0500

> We are interested in tcp tracing as well. Another requirement that
> we have that I don't think I saw is the ability to start/stop
> tracing on sockets (potentially multiple times) during the lifetime
> of a connection. So for example, the ability to use setsockopt(), to
> selectively start/stop tracing on a connection, so as not to incur
> overhead for non-traced sockets.

This is so backwards.

You make the tracing cheap enough that this can never be an issue.

Your requirement can only exist if the implementation is broken
by design.
