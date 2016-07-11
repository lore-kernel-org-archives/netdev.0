From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tunnels: correct conditional build of MPLS
 and IPv6
Date: Mon, 11 Jul 2016 13:27:33 -0700 (PDT)
Message-ID: <20160711.132733.449353383937689608.davem@davemloft.net>
References: <1468113611-21989-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbcGKU1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 16:27:35 -0400
In-Reply-To: <1468113611-21989-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Sun, 10 Jul 2016 10:20:11 +0900

> Using a combination if #if conditionals and goto labels to unwind
> tunnel4_init seems unwieldy. This patch takes a simpler approach of
> directly unregistering previously registered protocols when an error
> occurs.
> 
> This fixes a number of problems with the current implementation
> including the potential presence of labels when they are unused
> and the potential absence of unregister code when it is needed.
> 
> Fixes: 8afe97e5d416 ("tunnels: support MPLS over IPv4 tunnels")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied, thanks Simon.
