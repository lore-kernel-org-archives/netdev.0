From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sat, 02 Nov 2013 11:20:23 -0700
Message-ID: <1383416423.4291.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131029090849.GC5944@cpaasch-mac>
	 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383407176.2764.17.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, christoph.paasch@uclouvain.be,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:54546 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab3KBSU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 14:20:26 -0400
Received: by mail-pb0-f42.google.com with SMTP id jt11so5573083pbb.15
        for <netdev@vger.kernel.org>; Sat, 02 Nov 2013 11:20:26 -0700 (PDT)
In-Reply-To: <1383407176.2764.17.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-02 at 15:46 +0000, Ben Hutchings wrote:

> We should not change dev->wanted_features any more.  It should only be
> set as requested by userland.
> 
> Instead, netdev_update_features() should mask out NETIF_F_LRO based on
> dev->forwarding_count.

Oh right, I'll send a V4 to make the right thing in
netdev_fix_features()

Thanks !
