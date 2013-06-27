From: David Miller <davem@davemloft.net>
Subject: Re: fa_type and fib_info - a question
Date: Thu, 27 Jun 2013 16:17:44 -0700 (PDT)
Message-ID: <20130627.161744.674336032974965021.davem@davemloft.net>
References: <CAJJAcoeMwSTbSPCQYJa8e5ZNVqWRkP63PzLd3S2bAquD5uZk4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dshwatrz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707Ab3F0XRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 19:17:47 -0400
In-Reply-To: <CAJJAcoeMwSTbSPCQYJa8e5ZNVqWRkP63PzLd3S2bAquD5uZk4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Shwatrz <dshwatrz@gmail.com>
Date: Thu, 27 Jun 2013 22:16:12 +0300

> Why does fib_alias contain an fa_type member and also fib_info contain
> a fib_type member?  A fib_alias must refer to some fib_info object via
> the fa_info pointer. Are there cases when fa_type can differ from
> fib_type? or is it so only for some legacy reason?

It's just a simplification that hasn't been done yet.  They should
both be exactly the same and be derived from cfg->fc_type.
