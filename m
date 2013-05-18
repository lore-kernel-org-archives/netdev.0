From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sparc: bpf_jit_comp: can call module_free()
 from any context
Date: Fri, 17 May 2013 18:28:08 -0700 (PDT)
Message-ID: <20130517.182808.628687244899122243.davem@davemloft.net>
References: <1368828754.3301.116.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642Ab3ERB2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 21:28:09 -0400
In-Reply-To: <1368828754.3301.116.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 May 2013 15:12:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> module_free()/vfree() takes care of details, we no longer need a wrapper
> and a work_struct.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
