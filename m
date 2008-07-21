From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 11:16:27 +0100
Message-ID: <20080721101626.GM10471@solarflare.com>
References: <20080720.181440.122144107.davem@davemloft.net> <20080721024056.GA4800@martell.zuzino.mipt.ru> <20080720.194856.92564555.davem@davemloft.net> <20080720.221106.201055562.davem@davemloft.net> <a4423d670807210248l1e2e6999ha462edc99002f964@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, adobriyan@gmail.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.mbr-roch.zen.net.uk ([212.23.3.140]:48616 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757987AbYGUKQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 06:16:36 -0400
Content-Disposition: inline
In-Reply-To: <a4423d670807210248l1e2e6999ha462edc99002f964@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Beregalov wrote:
> Hi David!
> 
> There is another problem on sparc64 and happymeal ethernet card.
> 
> when tring to up interface:
> 
> kernel BUG at net/core/dev.c:1328
[...]

This is yet another driver calling netif_wake_queue() during dev_open(),
when there is no real qdisc present.  (And yes, sfc is another of those
drivers - I will post a patch after internal review.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
