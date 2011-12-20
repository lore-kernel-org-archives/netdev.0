From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] module_param: make bool parameters really bool
 (net & drivers/net)
Date: Tue, 20 Dec 2011 01:56:36 -0500 (EST)
Message-ID: <20111220.015636.1219874929301115567.davem@davemloft.net>
References: <87ehw1nm9r.fsf@rustcorp.com.au>
	<20111219.162210.1739976094495078504.davem@davemloft.net>
	<87fwggm7fi.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab1LTG6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 01:58:41 -0500
In-Reply-To: <87fwggm7fi.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 20 Dec 2011 10:38:01 +1030

> module_param(bool) used to counter-intuitively take an int.  In
> fddd5201 (mid-2009) we allowed bool or int/unsigned int using a messy
> trick.
> 
> It's time to remove the int/unsigned int option.  For this version
> it'll simply give a warning, but it'll break next kernel version.
> 
> (Thanks to Joe Perches for suggesting coccinelle for 0/1 -> true/false).
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied.
