From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] macsec: fix lockdep splats when nesting devices
Date: Sat, 13 Aug 2016 15:16:22 -0700 (PDT)
Message-ID: <20160813.151622.366324340238094901.davem@davemloft.net>
References: <4c1a6a53725cc0ec023f92dae1165f3ade1e7862.1470951139.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com,
	eric.dumazet@gmail.com, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35565 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199AbcHNIx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 04:53:29 -0400
In-Reply-To: <4c1a6a53725cc0ec023f92dae1165f3ade1e7862.1470951139.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 12 Aug 2016 16:10:32 +0200

> Currently, trying to setup a vlan over a macsec device, or other
> combinations of devices, triggers a lockdep warning.
> 
> Use netdev_lockdep_set_classes and ndo_get_lock_subclass, similar to
> what macvlan does.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied.
