From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] IPv6 Updates
Date: Wed, 21 Feb 2007 00:06:13 -0800 (PST)
Message-ID: <20070221.000613.55507332.davem@davemloft.net>
References: <E1HHRCL-00028w-00@gondolin.me.apana.org.au>
	<E1HHRj7-0002HG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hasso@estpak.ee, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	aramoto@linux-ipv6.org, kozakai@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37244
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751170AbXBUIGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 03:06:14 -0500
In-Reply-To: <E1HHRj7-0002HG-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 15 Feb 2007 08:31:45 +1100

> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > 
> > [IPV4] devinet: Register inetdev earlier.
> 
> I needed to move the panic call as well.
> 
> [IPV4] devinet: Register inetdev earlier.
> 
> This patch allocates inetdev at registration for all devices
> in line with IPv6.  This allows sysctl configuration on the
> devices to occur before they're brought up or addresses are
> added.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Since this technically fixes a major usability bug, I'm
happy to apply this with the ipv6 side for 2.6.21

It is up to Yoshifuji how to handle this.  He can either add
this patch to his ipv6 bug fix submission for 2.6.21, or he
can just submit the ipv6 parts and I can merge Herbert's ipv4
patch myself.

Just let me know what to do.
