From: Simon Horman <horms@verge.net.au>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when real-servers are removed
Date: Fri, 18 May 2007 10:06:52 +0900
Message-ID: <20070518010650.GB15229@verge.net.au>
References: <4648382E.8030009@trash.net> <20070514.033504.48528120.davem@davemloft.net> <4648714E.9050200@tis.icnet.pl> <464872E2.2030502@trash.net> <464884EE.3030606@tis.icnet.pl> <46489F5C.4000801@trash.net> <20070515052608.GG13708@verge.net.au> <4649DBB7.3070608@trash.net> <Pine.LNX.4.58.0705160012470.2626@u.domain.uli> <464C857C.9070406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>,
	Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:35008 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756918AbXERBG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 21:06:58 -0400
Content-Disposition: inline
In-Reply-To: <464C857C.9070406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 17, 2007 at 06:40:28PM +0200, Patrick McHardy wrote:
> 
> Actually thats exactly the case that my patch handles. Why does it
> matter which source address the ICMP packet uses, as long as its
> routed properly?

Agreed.

> In any case some better solution than the current one needs to be
> found, allowing users to send spoofed packets is far worse than
> using a non-desired source address for ICMP packets.

No agrument there.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

