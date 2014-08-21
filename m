From: David Miller <davem@davemloft.net>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 21 Aug 2014 16:24:06 -0700 (PDT)
Message-ID: <20140821.162406.2076033247433267586.davem@davemloft.net>
References: <53ED4354.9090904@intel.com>
	<20140814.162024.2218312002979492106.davem@davemloft.net>
	<CA+mtBx-c0HCAES9PCyGn7cChZsX0KaLgdziFL_e1iRmkdG0dsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295AbaHUXYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 19:24:07 -0400
In-Reply-To: <CA+mtBx-c0HCAES9PCyGn7cChZsX0KaLgdziFL_e1iRmkdG0dsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 14 Aug 2014 16:25:53 -0700

> I don't know if it's the same problem, but I did post a patch back in
> January that would resolve false sharing of dst->__refcnt and rt_genid
> in the same cacheline. We could revisit that if it helps.

I think that regardless of what happens in the discussion here, you
should repost that patch.
