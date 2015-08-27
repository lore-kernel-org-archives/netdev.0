From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/8] Geneve: Add support for tunnel
 metadata mode
Date: Thu, 27 Aug 2015 15:43:18 -0700 (PDT)
Message-ID: <20150827.154318.1386100823459130898.davem@davemloft.net>
References: <1440626079-11689-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754686AbbH0WnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 18:43:19 -0400
In-Reply-To: <1440626079-11689-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Wed, 26 Aug 2015 14:54:31 -0700

> Following patches adds support for Geneve tunnel metadata
> mode. OVS can make use of Geneve net-device with tunnel
> metadata API from kernel.
> 
> This also allows us to consolidate Geneve implementation
> from two kernel modules geneve_core and geneve to single
> geneve module. geneve_core module was targeted to share
> Geneve encap and decap code between Geneve netdevice and
> OVS Geneve tunnel implementation, Since OVS no longer
> needs these API, Geneve code can be consolidated into
> single geneve module.
> 
> v3-v4:
> - Drop NETIF_F_NETNS_LOCAL feature.
> - Fix geneve device newlink check
> 
> v2-v3:
> - make tunnel medata device and regular device mutually exclusive.
> - Fix Kconfig dependency for Geneve.
> - Fix dst-port netlink encoding.
> - drop changelink patch.
> 
> v1-v2:
> - Replaced per hash table tunnel pointer (metadata enabled) with flag.
> - Added support for changelink.
> - Improve geneve device route lookup with more parameters.

Series applied, but I kind of expect some sort of fallout from this
from the 0-day robot or similar :-)

We'll see.
