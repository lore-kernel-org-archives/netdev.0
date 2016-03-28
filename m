From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sxgbe: fix error paths in sxgbe_platform_probe()
Date: Sun, 27 Mar 2016 22:39:51 -0400 (EDT)
Message-ID: <20160327.223951.94101686178513680.davem@davemloft.net>
References: <877fgue1mx.fsf@rasmusvillemoes.dk>
	<1459027449-2667-1-git-send-email-linux@rasmusvillemoes.dk>
	<20160327082254.GA10620@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@rasmusvillemoes.dk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044AbcC1Cjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 22:39:53 -0400
In-Reply-To: <20160327082254.GA10620@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sun, 27 Mar 2016 10:22:54 +0200

> Two years after the initial submission, there is zero change regarding use
> of sxgbe_core_ops for extension or manageability. The extra indirection is
> ripe for removal during next net-next.

I completely agree, that stuff has to go.
