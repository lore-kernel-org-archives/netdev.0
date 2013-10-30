From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: extend net_device allocation to vmalloc()
Date: Wed, 30 Oct 2013 13:09:02 -0700
Message-ID: <1383163742.4857.55.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131029152628.GA3065@citrix.com>
	 <1383061430.5464.41.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029184647.GA3261@citrix.com>
	 <1383089055.4176.1.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383089532.4857.1.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131030103958.GB3261@citrix.com>
	 <1383141242.4857.36.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383145278.4857.46.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383160597.1601.14.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joby Poriyath <joby.poriyath@citrix.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com,
	xen-devel@lists.xen.org, andrew.bennieston@citrix.com,
	david.vrabel@citrix.com, malcolm.crossley@citrix.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:45545 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698Ab3J3UJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 16:09:05 -0400
Received: by mail-pd0-f182.google.com with SMTP id q10so1465642pdj.27
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 13:09:04 -0700 (PDT)
In-Reply-To: <1383160597.1601.14.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 19:16 +0000, Ben Hutchings wrote:
> , drivers must never try to allocate and initialise struct
> net_device from scratch.  They always call alloc_netdev_mqs() or one of
> its many wrappers.  So 'must be allocated with kmalloc' was already
> wrong and this sentence should be removed completely.

Right, I'll send a v2.
