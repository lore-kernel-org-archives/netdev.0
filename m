From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Thu, 22 May 2008 11:28:24 -0700 (PDT)
Message-ID: <20080522.112824.103189026.davem@davemloft.net>
References: <4835A007.7020601@krogh.cc>
	<20080522.104145.193700531.davem@davemloft.net>
	<20080522181420.GB28241@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, Matheos.Worku@Sun.COM, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41248
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbYEVS23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 14:28:29 -0400
In-Reply-To: <20080522181420.GB28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 22 May 2008 19:14:21 +0100

> David Miller wrote:
> > For now, yes.  The transmit path itself in the generic network
> > device layer is where the serialization comes from.
> 
> This is true in the general case, but can be substantially mitigated
> by segmentation offload.  Unfortunately GSO doesn't help much as the
> overhead of allocating the extra skbs is fairly high.

But GSO still does help a lot for chips that lack hw TSO support,
such as NIU, therefore sw GSO support in the NIU driver was pretty
high on my todo list.
