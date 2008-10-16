From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
 gc_elasticity is exceeded
Date: Thu, 16 Oct 2008 14:18:42 -0700 (PDT)
Message-ID: <20081016.141842.223137278.davem@davemloft.net>
References: <20081013182655.GA9505@hmsreliant.think-freely.org>
	<20081015.235556.61915120.davem@davemloft.net>
	<48F7072A.908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57605
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752941AbYJPVTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 17:19:06 -0400
In-Reply-To: <48F7072A.908@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 16 Oct 2008 11:19:38 +0200

> While browsing Neil patch, I found one missing rcu_assign_pointer()
> in current code. I added a comment similar to other rcu_assign_pointer()
> in rt_intern_hash() function.
> 
> [PATCH] ip: adds a missing rcu_assign_pointer()
> 
> rt_intern_hash() is doing an update of a RCU guarded hash chain
> without using rcu_assign_pointer() or equivalent barrier.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
