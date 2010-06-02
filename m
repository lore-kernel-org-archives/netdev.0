From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: 64-bit net_device_stats
Date: Wed, 2 Jun 2010 14:59:12 -0700
Message-ID: <20100602145912.56ef62c2@nehalam>
References: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
	<20100525.161539.104072714.davem@davemloft.net>
	<1275514469.2115.70.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, junchangwang@gmail.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34562 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758641Ab0FBV7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 17:59:19 -0400
In-Reply-To: <1275514469.2115.70.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Jun 2010 22:34:29 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> Changing the counter types to u64 for 32-bit architectures would remove
> atomicity and expose half-updated counters to userland.  Changing the
> driver interface significantly so that atomicity is not needed would
> require changes to hundreds of drivers.

Another big issue is maintaining ABI compatibility for /proc and ioctl
interfaces. So bigger values would only be available through netlink,
and most applications using counters don't use netlink. 

-- 
