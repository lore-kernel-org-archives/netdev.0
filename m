From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] IOC3: Switch hw checksumming to ethtool configurable.
Date: Mon, 30 Jul 2007 16:06:54 -0400
Message-ID: <46AE44DE.8000107@garzik.org>
References: <20070725113157.GA29416@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55816 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935071AbXG3UG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 16:06:58 -0400
In-Reply-To: <20070725113157.GA29416@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

applied to #upstream (2.6.24)


> I've previously sent out this patch a long time ago.  At that time I was
> told NETIF_F_IP_CSUM wouldn't make any sense without NETIF_F_SG.  IOC3's
> S/G abilities are very limited; it can do upto three segments of which
> the first one is upto 104 bytes and part of the packet's TX ring entry,
> the second and 3rd ones can be anywhere in the 64-bit PCI address space
> but may not cross a 16kB page boundary.  So setting NETIF_F_SG isn't
> really an option unless the IOC3 was going to linearize any packet it
> can't cope with itself.
> 
> So the big question, does NETIF_F_IP_CSUM without NETIF_F_SG make sense?

Conventional wisdom has always been that NETIF_F_SG is required if 
NETIF_F_*CSUM is present, and vice versa.

I admit I've not verified this in the past year or two.

	Jeff


