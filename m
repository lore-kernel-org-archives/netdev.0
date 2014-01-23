From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Linux kernel patch: elide fib_validate_source() completely when possible - bad side effect?
Date: Thu, 23 Jan 2014 03:02:24 +0100
Message-ID: <20140123020224.GG7269@order.stressinduktion.org>
References: <52D945400200005D00047758@gwia2.atlnz.lc> <alpine.LFD.2.11.1401170953370.1827@ja.home.ssi.bg> <52DCF1440200005D000477FD@gwia2.atlnz.lc> <alpine.LFD.2.11.1401222222010.1855@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: gregory hoggarth <gregory.hoggarth@alliedtelesis.co.nz>,
	netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59359 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbaAWCCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 21:02:25 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1401222222010.1855@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 11:04:52PM +0200, Julian Anastasov wrote:
> 	I don't remember someone mentioning about such
> side-effect, I guess it is overlooked. IMHO, it is not a good
> reason to restore the old behavior. Lets see other opinions.

A routing lookup to check for broadcast is much too expansive, I agree. But
can't we just check skb->pkt_type == PACKET_BROADCAST?

Greetings,

  Hannes
