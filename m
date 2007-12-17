From: Sami Farin <safari-netfilter@safari.iki.fi>
Subject: Re: [NETFILTER] xt_hashlimit : speedups hash_dst()
Date: Mon, 17 Dec 2007 16:04:42 +0200
Message-ID: <20071217140442.efbpwsc2uhqvnkfp@m.safari.iki.fi>
References: <4762F78B.80302@cosmosbay.com> <4763AF65.4070200@gmail.com> <4763B4CF.7010908@cosmosbay.com> <20071215.214219.129511362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, jarkao2@gmail.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:38628 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754507AbXLQOEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 09:04:46 -0500
Received: from safari.iki.fi (84.249.185.191) by pne-smtpout4-sn2.hy.skanova.net (7.3.129)
        id 471A7B0C0032720D for netdev@vger.kernel.org; Mon, 17 Dec 2007 15:03:51 +0100
Content-Disposition: inline
In-Reply-To: <20071215.214219.129511362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 15, 2007 at 21:42:19 -0800, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sat, 15 Dec 2007 12:04:47 +0100
> 
> > I prefer to let admins chose their size, since it makes attacker life more 
> > difficult :)
> > 
> > For example, I can tell you I have a server, were size is between 2.000.000 
> > and 3.500.000, I dont want to be forced to use 2097152
> > 
> > A multiply is cheap, at least on current hardware.
> 
> I agree, and I see nothing wrong with Eric's patch and it
> should be merged ASAP.

You could do the same optimization for 
net/netfilter/nf_conntrack_core.c:__hash_conntrack() , too.

-- 
Do what you love because life is too short for anything else.

