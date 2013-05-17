From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: can call module_free()
 from any context
Date: Fri, 17 May 2013 14:19:52 -0700 (PDT)
Message-ID: <20130517.141952.581871611521516663.davem@davemloft.net>
References: <1368769530.3301.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@ZenIV.linux.org.uk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756464Ab3EQVTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 17:19:54 -0400
In-Reply-To: <1368769530.3301.81.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 May 2013 22:45:30 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> It looks like we can call module_free()/vfree() from softirq context,
> so no longer need a wrapper and a work_struct.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
