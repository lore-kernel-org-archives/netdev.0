From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] can use __get_cpu_var() instead of per_cpu() in
 loopback driver
Date: Fri, 20 Oct 2006 00:32:48 -0700 (PDT)
Message-ID: <20061020.003248.133286934.davem@davemloft.net>
References: <452EA214.7080905@cosmosbay.com>
	<4535B6B7.4070107@cosmosbay.com>
	<4538784B.2000306@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51672
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S2992561AbWJTHdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 03:33:00 -0400
To: dada1@cosmosbay.com
In-Reply-To: <4538784B.2000306@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 20 Oct 2006 09:18:35 +0200

> As BHs are off in loopback_xmit(), preemption cannot occurs, so we can use 
> __get_cpu_var() instead of per_cpu() (and avoid a 
> preempt_enable()/preempt_disable() pair)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
