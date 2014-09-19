From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix sparse warnings in
 SNMP_UPD_PO_STATS(_BH)
Date: Fri, 19 Sep 2014 17:22:57 -0400 (EDT)
Message-ID: <20140919.172257.1570134006629760373.davem@davemloft.net>
References: <20140917212312.GA13866@kria>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757728AbaISVW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:22:59 -0400
In-Reply-To: <20140917212312.GA13866@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Wed, 17 Sep 2014 23:23:12 +0200

> ptr used to be a non __percpu pointer (result of a this_cpu_ptr
> assignment, 7d720c3e4f0c4 ("percpu: add __percpu sparse annotations to
> net")). Since d25398df59b56 ("net: avoid reloads in SNMP_UPD_PO_STATS"),
> that's no longer the case, SNMP_UPD_PO_STATS uses this_cpu_add and ptr
> is now __percpu.
> 
> Silence sparse warnings by preserving the original type and
> annotation, and remove the out-of-date comment.
> 
> warning: incorrect type in initializer (different address spaces)
>    expected unsigned long long *ptr
>    got unsigned long long [noderef] <asn:3>*<noident>
> warning: incorrect type in initializer (different address spaces)
>    expected void const [noderef] <asn:3>*__vpp_verify
>    got unsigned long long *<noident>
> warning: incorrect type in initializer (different address spaces)
>    expected void const [noderef] <asn:3>*__vpp_verify
>    got unsigned long long *<noident>
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thanks.
