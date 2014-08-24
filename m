From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Sat, 23 Aug 2014 21:26:07 -0700 (PDT)
Message-ID: <20140823.212607.1097729413788303793.davem@davemloft.net>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
	<CA+mtBx_FH07PTRS8Bbuh9QoWRNgiEFd2CjEtKa2XJwh1rb5CuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbaHXE0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 00:26:11 -0400
In-Reply-To: <CA+mtBx_FH07PTRS8Bbuh9QoWRNgiEFd2CjEtKa2XJwh1rb5CuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sat, 23 Aug 2014 20:39:05 -0700

> Interesting, but I'm still wondering about MSG_MORE idea. If that is
> passed with ndo_start_xmit than maybe a new ndo function might not be
> needed. Also, since it's advisory, we could pass it to existing
> drivers and let them decide how rather to do anything with it.

My thinking is that if we can have the flush generation logic in a
generic place, we should.

We really do not want every driver to have a unique approach to this
stuff.
