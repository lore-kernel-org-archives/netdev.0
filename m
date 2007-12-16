From: David Miller <davem@davemloft.net>
Subject: Re: [NETFILTER] xt_hashlimit : speedups hash_dst()
Date: Sat, 15 Dec 2007 21:42:19 -0800 (PST)
Message-ID: <20071215.214219.129511362.davem@davemloft.net>
References: <4762F78B.80302@cosmosbay.com>
	<4763AF65.4070200@gmail.com>
	<4763B4CF.7010908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48744
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752080AbXLPFmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 00:42:19 -0500
In-Reply-To: <4763B4CF.7010908@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 15 Dec 2007 12:04:47 +0100

> I prefer to let admins chose their size, since it makes attacker life more 
> difficult :)
> 
> For example, I can tell you I have a server, were size is between 2.000.000 
> and 3.500.000, I dont want to be forced to use 2097152
> 
> A multiply is cheap, at least on current hardware.

I agree, and I see nothing wrong with Eric's patch and it
should be merged ASAP.
