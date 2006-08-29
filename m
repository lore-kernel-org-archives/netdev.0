From: Olaf Kirch <okir@suse.de>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 12:45:24 +0200
Message-ID: <20060829104524.GJ1201@suse.de>
References: <20060829.025400.37356422.davem@davemloft.net> <E1GI10b-0002d3-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, jbeulich@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44683 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932268AbWH2Kpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 06:45:34 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1GI10b-0002d3-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2006 at 08:39:53PM +1000, Herbert Xu wrote:
> Netfilter is broken for a different reason.  It breaks because packets
> pass through it twice, once going through brigde netfilter and once
> through the Xen netloop interface.  So ideally they'd get rid of the
> netloop device in which case they won't have to disable multicasting
> on the bridge device anymore.

I agree, this would be the right long-term fix.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
