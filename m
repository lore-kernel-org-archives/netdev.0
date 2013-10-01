From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/4] ip_tunnel: Add fallback tunnels to the hash
 lists
Date: Tue, 01 Oct 2013 12:43:21 -0400 (EDT)
Message-ID: <20131001.124321.664521927472651169.davem@davemloft.net>
References: <20131001093359.GG7660@secunet.com>
	<20131001093448.GH7660@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab3JAQnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:43:23 -0400
In-Reply-To: <20131001093448.GH7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 1 Oct 2013 11:34:48 +0200

> Currently we can not update the tunnel parameters of
> the fallback tunnels because we don't find them in the
> hash lists. Fix this by adding them on initialization.
> 
> Bug was introduced with commit c544193214
> ("GRE: Refactor GRE tunneling code.")
> 
> Cc: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable.
