From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Prevent UDP tunnels from operating on garbage
 socket
Date: Mon, 06 Apr 2015 15:38:57 -0400 (EDT)
Message-ID: <20150406.153857.2087257516868035001.davem@davemloft.net>
References: <20150406.124114.924455461962119301.davem@davemloft.net>
	<20150406.131700.185460014498109286.davem@davemloft.net>
	<CALx6S34CvOZN3dZjXr6_1afCbUDu2718cCGPk2Sm1Nkq8wCGKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, jiri@resnulli.us, pablo@netfilter.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbbDFTjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 15:39:01 -0400
In-Reply-To: <CALx6S34CvOZN3dZjXr6_1afCbUDu2718cCGPk2Sm1Nkq8wCGKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 6 Apr 2015 10:27:31 -0700

> Seems like this is creating inconsistencies with other tunneling. We don't
> have socket for GRE, IPIP, or and there's no concept of a udp socket for
> GUE.

In those cases, we'll pass a NULL socket down and routines like sk_mc_loop()
can accommodate that.
