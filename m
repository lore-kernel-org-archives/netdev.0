From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Fix IXP4xx coherent allocations
Date: Sat, 30 Mar 2013 14:18:12 +0100
Message-ID: <m3li95f2ln.fsf@intrepid.localdomain>
References: <m3obe9lxil.fsf@intrepid.localdomain>
	<20130323.195740.2108147521543354261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, c.aeschlimann@acn-group.ch
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:46097 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756024Ab3C3NSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Mar 2013 09:18:15 -0400
In-Reply-To: <20130323.195740.2108147521543354261.davem@davemloft.net> (David
	Miller's message of "Sat, 23 Mar 2013 19:57:40 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

>> ARM core code currently requires coherent DMA mask to be set.

> This requirement is not reasonable.
>
> The DMA API documentation clearly states what the default must be,
> and what drivers are guarenteed will be the default.

ARM people - what do you think?
-- 
Krzysztof Halasa
