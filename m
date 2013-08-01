From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] tcp_metrics: rearrange fields to avoid holes
Date: Thu, 01 Aug 2013 00:15:51 -0700 (PDT)
Message-ID: <20130801.001551.84126063849926109.davem@davemloft.net>
References: <1375240402.22980.5.camel@cr0>
	<20130730.232639.178259761581407616.davem@davemloft.net>
	<1375325311.7780.9.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, ycheng@google.com, ncardwell@google.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab3HAHPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 03:15:55 -0400
In-Reply-To: <1375325311.7780.9.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 01 Aug 2013 10:48:31 +0800

> Please teach me how to do that?

struct inet_addr {
	union {
		u32	v4;
		u32	v6[4];
	};
};

ie. exactly what that code is using already.

And it's called called inetpeer_addr, we have it already, there is no
need to make something new.

Making this code use a structure with completely unnecessary and
unused members is pointless and a step backwards.
