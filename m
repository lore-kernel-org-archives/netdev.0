From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: 64-bit net_device_stats
Date: Fri, 4 Jun 2010 09:59:59 +0800
Message-ID: <20100604015956.GA10971@host-a-55.ustcsz.edu.cn>
References: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
 <20100525.161539.104072714.davem@davemloft.net>
 <1275514469.2115.70.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:55591 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677Ab0FDB7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 21:59:48 -0400
Received: by pxi8 with SMTP id 8so51427pxi.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 18:59:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1275514469.2115.70.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Wed, Jun 02, 2010 at 10:34:29PM +0100, Ben Hutchings wrote:
>Changing the counter types to u64 for 32-bit architectures would remove
>atomicity and expose half-updated counters to userland.  Changing the
>driver interface significantly so that atomicity is not needed would
>require changes to hundreds of drivers.
>
>Assuming the above is all correct, I think we can only solve this with a
>gradual change (as for net_device_ops).  The following might work:
>
I realized the network team doesn't care about 64-bit counters (especially rx_*) on 32-bit systems. A similar disscussion can be found here:
http://www.gossamer-threads.com/lists/linux/kernel/282631?search_string=64%20stats;#282631

And Eric just gave a explanation why they stand by that point. Updating rx_* counters in core network will dirty a cache line.

--Junchang
