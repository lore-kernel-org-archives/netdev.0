From: George Kargiotakis <kargig@void.gr>
Subject: Re: Linux kernel handling of IPv6 temporary addresses
Date: Thu, 15 Nov 2012 01:03:24 +0200
Message-ID: <20121115010324.2707950c@lola.kot>
References: <20121114231411.4328fc47@lola.kot>
	<20121114.162956.610530798200803185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting-16.ecomm.gr ([85.17.213.16]:36711 "EHLO foo.wimax.gr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932216Ab2KNXD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 18:03:26 -0500
In-Reply-To: <20121114.162956.610530798200803185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Nov 2012 16:29:56 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: George Kargiotakis <kargig@void.gr>
> Date: Wed, 14 Nov 2012 23:14:11 +0200
> 
> > Due to the way the Linux kernel handles the creation of IPv6
> > temporary addresses a malicious LAN user can remotely disable them
> > altogether which may lead to privacy violations and information
> > disclosure.
> 
> A malicious user who can emit random packets as root on your LAN can
> also corrupt your ARP cache with entries that point to the wrong MAC
> address.
> 
> What's your point?

Hello,

I think it's an issue that a LAN root user can disable a
locally enabled kernel "feature" for good. The kernel could provide a
somewhat more informative message on such an occasion taking place,
since it knows that max_addresses limit has been reached and it's not a
DAD failure.

My point is that I'd like the kernel to handle this situation a bit 
differently than it currently does.

Best regards,
-- 
George Kargiotakis
https://void.gr
GPG KeyID: 0xE4F4FFE6
GPG Fingerprint: 9EB8 31BE C618 07CE 1B51 818D 4A0A 1BC8 E4F4 FFE6
