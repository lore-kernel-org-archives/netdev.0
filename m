From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: avoid a possible divide by zero
Date: Wed, 08 Dec 2010 12:35:36 -0800 (PST)
Message-ID: <20101208.123536.15249027.davem@davemloft.net>
References: <1291757288.5324.18.camel@edumazet-laptop>
	<1291757563.21627.15.camel@bwh-desktop>
	<1291759435.5324.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, Martin@lichtvoll.de,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47047
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755453Ab0LHUfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 15:35:09 -0500
In-Reply-To: <1291759435.5324.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Dec 2010 23:03:55 +0100

> [PATCH v2] tcp: avoid a possible divide by zero
> 
> sysctl_tcp_tso_win_divisor might be set to zero while one cpu runs in
> tcp_tso_should_defer(). Make sure we dont allow a divide by zero by
> reading sysctl_tcp_tso_win_divisor exactly once.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
