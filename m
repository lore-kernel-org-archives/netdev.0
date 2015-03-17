From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 3/3] Validate all netlink attributes and
 return error if any of the validation fails.
Date: Tue, 17 Mar 2015 02:37:38 -0400 (EDT)
Message-ID: <20150317.023738.194707115141514694.davem@davemloft.net>
References: <5269ddae1a0a164a488703654c9bb6e24845c637.1426509272.git.siva.mannem.lnx@gmail.com>
	<20150317.002427.1841301696338614194.davem@davemloft.net>
	<CA+CtxLRR1LiotUPk=Pi995+6PF8ys72Zx1xbAevX7CTF9H4u9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com
To: siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbbCQGhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 02:37:43 -0400
In-Reply-To: <CA+CtxLRR1LiotUPk=Pi995+6PF8ys72Zx1xbAevX7CTF9H4u9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Mannem <siva.mannem.lnx@gmail.com>
Date: Tue, 17 Mar 2015 10:29:28 +0530

> As Scott mentioned,  these functions can be enhanced to take
> extra argument to avoid extra range checking happening in br_changelink()
> path. Is this approach ok?

Make validation helper inline functions, call them from the individual
sysfs call sites and from br_changelink().
